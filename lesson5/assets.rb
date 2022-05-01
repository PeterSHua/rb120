module Assets
  class Deck
    include Console

    # Deck of cards have the following structure:
    # {
    #   heart: [2, 3, 4, 5, 6, 7, 8, 9, 10, jack, queen, king, ace]
    #   diamond: [...]
    #   club: [...]
    #   spade: [...]
    # }
    def initialize
      self.cards = Card::SUITS.each_with_object(Hash.new) do |suit_name, cards|
        cards[suit_name] = Card::FACELESS + Card::FACES + Card::TWO_FACED
      end
    end

    def deal(player)
      prompt "#{MSGS['dealing']} #{player.name}..."

      card = rand_card
      player.update_hand(card)

      card
    end

    private

    attr_accessor :cards

    def rand_suit
      loop do
        drawn_suit = cards.keys.sample
        return drawn_suit if !cards[drawn_suit].empty?
      end
    end

    def rand_card
      suit = rand_suit
      head = cards[suit].sample

      cards[suit].delete(head)

      Card.new(suit, head)
    end
  end

  class Card
    include Console

    SUITS = %w(heart diamond club spade)
    FACELESS = (2..10).to_a
    FACES = %w(Jack Queen King)
    FACE_VALUE = 10
    TWO_FACED = %w(Ace)
    TWO_FACED_MAX = 11
    TWO_FACED_MIN = 1

    attr_reader :suit, :head

    def initialize(suit, head)
      self.suit = suit
      self.head = head
    end

    def to_s
      "#{head}#{MSGS[suit]}"
    end

    def print(mask = false)
      if !mask
        prompt("#{head} #{MSGS['of']} #{MSGS[suit]}")
      end

      wait_user
      clear_screen
    end

    private

    attr_writer :suit, :head
  end

  class Player
    include Console

    BLACKJACK = 21

    attr_reader :hand, :score, :name, :total_sum

    def initialize(name)
      self.score = 0
      self.name = name
      reset_hand
    end

    def reset_hand
      self.hand = []
      self.total_sum = 0
      self.ace_count = 0
      self.non_ace_sum = 0
      self.ace_sum = 0
    end

    def dealer?
      self.class == Dealer
    end

    def stay?
      return true if blackjack?

      options = [MSGS['hit'], MSGS['stay']]
      msg = "#{MSGS['decision']} #{joinor(options)}"

      hit_rgx = /^[\sh]/i
      stay_rgx = /^[\ss]/i

      stay = bool_choice(msg, stay_rgx, hit_rgx)
      prompt "#{name} #{MSGS['stays']}" if stay

      wait_user

      stay
    end

    def busted?
      total_sum > BLACKJACK
    end

    def blackjack?
      total_sum == BLACKJACK
    end

    # rubocop: disable Metrics/AbcSize
    def update_hand(card)
      hand << card

      self.non_ace_sum += card.head if Card::FACELESS.include?(card.head)
      self.non_ace_sum += Card::FACE_VALUE if Card::FACES.include?(card.head)

      self.ace_count += 1 if Card::TWO_FACED.include?(card.head)
      self.ace_sum = calc_aces if !ace_count.zero?

      self.total_sum = non_ace_sum + ace_sum
    end
    # rubocop: enable Metrics/AbcSize

    def reset_score
      self.score = 0
    end

    def update_score
      self.score += 1
    end

    def print_score
      puts "#{name} (#{MSGS['score']}: #{score})"
    end

    # The dealer's second card is hidden until it's their turn
    def mask_hand(mask = false, mask_idx = nil)
      cards = hand.dup

      if dealer? && hole? && mask
        cards[mask_idx] = MSGS['hidden']
        sum = MSGS['hidden']
      else
        sum = total_sum
      end

      [cards, sum]
    end

    def print_hand_total(mask = false, mask_idx = nil)
      cards, sum = mask_hand(mask, mask_idx)
      cards = if cards.empty?
                MSGS['empty']
              else
                joinor(cards, ', ', 'and')
              end

      puts "#{MSGS['hand']}: #{cards}"
      puts "#{MSGS['total']} #{sum}"
    end

    private

    attr_accessor :ace_count, :non_ace_sum, :ace_sum
    attr_writer :hand, :score, :name, :total_sum

    # Returns the sum of aces in the player's hand.
    # Aces may have a value of 1 or 11, but there may only be one ace with a
    # value of 11, in any hand, without busting. We make an assumption that
    # one ace in a hand is 11, all other ace's are 1. If this assupmtion
    # causes the hand to bust, we make all ace's 1. Otherwise, we make one
    # ace 11 and all other ace's 1, for the best possible hand.
    # Examples:
    # Hand is [2, 3, ace, ace]      => values are [2, 3, 11, 1]
    # Hand is [2, 3, ace, ace, ace] => values are [2, 3, 1, 1, 1]
    # Hand is [10, ace]             => values are [10, 11]
    # Hand is [10, 10, ace]         => values are [10, 10, 1]
    def calc_aces
      total_sum_w_high_ace = non_ace_sum + Card::TWO_FACED_MAX +
                             (ace_count - 1) * Card::TWO_FACED_MIN

      total_sum_w_low_ace = non_ace_sum +
                            ace_count * Card::TWO_FACED_MIN

      self.total_sum = if total_sum_w_high_ace <= BLACKJACK
                         total_sum_w_high_ace
                       else
                         total_sum_w_low_ace
                       end

      total_sum - non_ace_sum
    end
  end

  class Dealer < Player
    HOUSE_RULE = 17
    HOLE = 2
    NAMES = %w(Chico Harpo Groucho Gummo Zeppo)

    def initialize
      super(NAMES.sample)
    end

    def stay?
      if total_sum >= HOUSE_RULE
        prompt("#{name} #{MSGS['stays']}")
        true
      else
        prompt("#{name} #{MSGS['hits']}")
        false
      end
    end

    def hole?
      hand.count == HOLE
    end

    def next_hole?
      hand.count == HOLE - 1
    end

    def print_score
      print "Dealer: "
      super
    end
  end
end
