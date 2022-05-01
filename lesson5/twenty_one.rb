require_relative 'console'
require_relative 'assets'
require_relative 'twenty_one_hud'

class TwentyOne
  include Console
  include Assets

  DEAL_TIMES = 4
  SCORE_LIMIT = 5

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
        wait_user(MSGS['wait_user'])
      end

      discard_hands
      self.deck = Deck.new
    end
  end
  # rubocop: enable Metrics/MethodLength

  private

  include TwentyOneHUD

  attr_accessor :deck, :gambler, :dealer, :players

  def calc_player_idx(idx)
    idx % players.count
  end

  # rubocop: disable Metrics/MethodLength
  def deal_cards
    DEAL_TIMES.times do |idx|
      # We don't show the dealer's second card and their hand's value until
      # it's the dealer's turn.
      mask = dealer.hand.hole?

      draw_table(mask)

      player_idx = calc_player_idx(idx)
      curr_player = players[player_idx]

      # We don't show the dealer's next card draw, if it is their second card.
      mask = if curr_player == dealer && dealer.hand.next_hole?
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
      break if gambler.hand.blackjack?

      players.each do |player|
        next if player.hand.blackjack?

        loop do
          draw_table(!player.dealer?)

          if player.hand.busted?
            player.print_busted
            throw :round_over
          elsif player.stay?
            player.print_stood
            break
          end

          player.print_hit
          draw_table(!player.dealer?)

          card = deck.deal(player)
          card.print
        end
      end
    end
  end
  # rubocop: enable Metrics/MethodLength, Metrics/AbcSize

  def flop
    winner = compare_hands
    winner&.scoreboard&.increment

    draw_table
    result(winner)
  end

  # Returns the player that won. Returns nil if tied.
  def compare_hands
    if gambler.hand.busted?
      dealer
    elsif dealer.hand.busted?
      gambler
    else
      case gambler.hand.total_sum <=> dealer.hand.total_sum
      when -1 then dealer
      when 1 then gambler
      end
    end
  end

  def result(winner)
    if winner.nil?
      declare_tie
    else
      declare_winner(winner.name)
    end
  end

  def over?
    players.each do |player|
      if player.scoreboard.points == SCORE_LIMIT
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

    bool_choice(msg, yes_rgx, no_rgx, msg)
  end

  def reset_scores
    players.each do |player|
      player.scoreboard.reset
    end
  end

  def discard_hands
    players.each do |player|
      player.hand.reset
    end
  end
end

TwentyOne.new.start
