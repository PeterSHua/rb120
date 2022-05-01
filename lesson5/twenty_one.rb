require_relative 'console'
require_relative 'assets'

class Game
  include Console
  include Assets

  DEAL_TIMES = 4
  SCORE_LIMIT = 5
  PLAYER_DIVIDER = '-'
  TABLE_DIVIDER = '='
  SCREEN_LENGTH = 80

  def initialize
    self.deck = Deck.new
    self.gambler = Player.new(req_player_name)
    self.dealer = Dealer.new
    self.players = [gambler, dealer]
  end

  # rubocop: disable Metrics/MethodLength
  def start
    rules

    loop do
      deal_cards
      player_turns
      flop

      if over?
        break unless again?
        reset_scores
      else
        wait_user
      end

      discard_hands
      self.deck = Deck.new
    end
  end
  # rubocop: enable Metrics/MethodLength

  private

  attr_accessor :deck, :gambler, :dealer, :players

  def req_player_name
    clear_screen
    prompt(MSGS['your_name'])

    loop do
      user_input = gets.chomp
      return user_input unless user_input.empty? || /[^a-z]/i.match?(user_input)
      prompt(MSGS['valid_name'])
    end
  end

  def rules
    prompt(MSGS['begin'])
    user_input = gets.chomp

    return unless /^[\sr]/i.match?(user_input)

    clear_screen

    puts MSGS['rules']
    puts

    wait_user
    clear_screen
  end

  def player_divider
    puts PLAYER_DIVIDER * SCREEN_LENGTH
  end

  def table_divider
    puts TABLE_DIVIDER * SCREEN_LENGTH
  end

  def print_hands(mask = false, mask_idx = nil)
    players.each do |player|
      player.print_score
      player.print_hand_total(mask, mask_idx)
      player_divider if player != players.last
    end
  end

  def print_table(mask = false, mask_idx = nil)
    clear_screen
    print_hands(mask, mask_idx)
    table_divider
  end

  def calc_player_idx(idx)
    idx % players.count
  end

  # rubocop: disable Metrics/MethodLength
  def deal_cards
    DEAL_TIMES.times do |idx|
      # We don't show the dealer's second card and their hand's value until
      # it's the dealer's turn.
      mask = dealer.hole?

      print_table(mask, Dealer::HOLE - 1)

      player_idx = calc_player_idx(idx)
      curr_player = players[player_idx]

      # We don't show the dealer's next card draw, if it is their second card.
      mask = if curr_player == dealer && dealer.next_hole?
               true
             else
               false
             end

      card = deck.deal(curr_player)
      card.print(mask)
    end
  end
  # rubocop: enable Metrics/MethodLength

  # rubocop: disable Metrics/MethodLength, Metrics/AbcSize
  def player_turns
    catch :round_over do
      break if gambler.blackjack?

      players.each do |player|
        next if player.blackjack?

        loop do
          print_table(!player.dealer?, Dealer::HOLE - 1)

          if player.busted?
            prompt("#{player.name} #{MSGS['busts']}")
            wait_user
            throw :round_over
          elsif player.stay?
            break
          end

          print_table(!player.dealer?, Dealer::HOLE - 1)

          card = deck.deal(player)
          card.print
        end
      end
    end
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize

  def flop
    winner = compare_hands
    winner&.update_score

    print_table
    result(winner)
  end

  # Returns the player that won. Returns nil if tied.
  def compare_hands
    if gambler.busted?
      dealer
    elsif dealer.busted?
      gambler
    else
      case gambler.total_sum <=> dealer.total_sum
      when -1 then dealer
      when 1 then gambler
      end
    end
  end

  def result(winner)
    if winner.nil?
      prompt(MSGS['tie'])
    else
      prompt("#{winner.name} #{MSGS['win_round']}")
    end
  end

  def over?
    players.each do |player|
      if player.score == SCORE_LIMIT
        prompt("#{player.name} #{MSGS['win_game']}")
        return true
      end
    end

    false
  end

  def again?
    msg = MSGS['again']

    yes_rgx = /\by/i
    no_rgx = /\bn/i

    bool_choice(msg, yes_rgx, no_rgx)
  end

  def reset_scores
    players.each(&:reset_score)
  end

  def discard_hands
    players.each(&:reset_hand)
  end
end

Game.new.start
