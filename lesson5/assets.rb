require 'yaml'

module Assets
  MSGS = YAML.load_file('assets.yml')

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
      player.hand.add(card)

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

      wait_user(MSGS['wait_user'])
      clear_screen
    end

    private

    attr_writer :suit, :head
  end

  class Player
    include Console

    attr_reader :hand, :scoreboard, :name

    def initialize(name)
      self.scoreboard = Scoreboard.new
      self.name = name
      self.hand = Hand.new
    end

    def dealer?
      self.class == Dealer
    end

    def stay?
      return true if hand.blackjack?

      options = [MSGS['hit'], MSGS['stay']]
      msg = "#{MSGS['decision']} #{joinor(options)}"

      hit_rgx = /^[\sh]/i
      stay_rgx = /^[\ss]/i

      bool_choice(msg, stay_rgx, hit_rgx, msg)
    end

    def print_busted
      prompt("#{name} #{MSGS['busts']}")
      wait_user(MSGS['wait_user'])
    end

    def print_stood
      prompt("#{name} #{MSGS['stays']}")
      wait_user(MSGS['wait_user'])
    end

    def print_hit
      prompt("#{name} #{MSGS['hits']}")
      wait_user(MSGS['wait_user'])
    end

    private

    attr_accessor :ace_count, :non_ace_sum, :ace_sum
    attr_writer :hand, :scoreboard, :name
  end

  class Dealer < Player
    HOUSE_RULE = 17
    NAMES = %w(Chico Harpo Groucho Gummo Zeppo)

    def initialize
      super(NAMES.sample)
    end

    def stay?
      hand.total_sum >= HOUSE_RULE
    end
  end

  class Hand
    include Console

    BLACKJACK = 21
    HOLE = 2

    attr_reader :cards, :total_sum, :ace_count, :non_ace_sum, :ace_sum

    def initialize
      reset
    end

    def reset
      self.cards = []
      self.total_sum = 0
      self.ace_count = 0
      self.non_ace_sum = 0
      self.ace_sum = 0
    end

    def hole?
      cards.count == HOLE
    end

    def next_hole?
      cards.count == HOLE - 1
    end

    def busted?
      total_sum > BLACKJACK
    end

    def blackjack?
      total_sum == BLACKJACK
    end

    # rubocop: disable Metrics/AbcSize
    def add(card)
      cards << card

      self.non_ace_sum += card.head if Card::FACELESS.include?(card.head)
      self.non_ace_sum += Card::FACE_VALUE if Card::FACES.include?(card.head)

      self.ace_count += 1 if Card::TWO_FACED.include?(card.head)
      self.ace_sum = calc_aces if !ace_count.zero?

      self.total_sum = non_ace_sum + ace_sum
    end
    # rubocop: enable Metrics/AbcSize

    def print(mask = false)
      cards, sum = hide(mask)
      cards = if cards.empty?
                MSGS['empty']
              else
                joinor(cards, ', ', MSGS['and'])
              end

      puts "#{MSGS['hand']}: #{cards}"
      puts "#{MSGS['total']} #{sum}"
    end

    private

    attr_writer :cards, :total_sum, :ace_count, :non_ace_sum, :ace_sum

    # The dealer's second card is hidden until it's their turn
    def hide(mask = false)
      dup_cards = cards.dup

      if hole? && mask
        dup_cards[HOLE - 1] = MSGS['hidden']
        sum = MSGS['hidden']
      else
        sum = total_sum
      end

      [dup_cards, sum]
    end

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

  class Scoreboard
    attr_reader :points

    def initialize
      reset
    end

    def reset
      self.points = 0
    end

    def increment
      self.points += 1
    end

    def print(name)
      puts "#{name} (#{MSGS['score']}: #{points})"
    end

    private

    attr_writer :points
  end
end
