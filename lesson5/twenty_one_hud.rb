require 'yaml'

module TwentyOneHUD
  MSGS = YAML.load_file('twenty_one_hud.yml')
  PLAYER_DIVIDER = '-'
  TABLE_DIVIDER = '='
  SCREEN_LENGTH = 80

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

    wait_user(MSGS['wait_user'])
    clear_screen
  end

  def player_divider
    puts PLAYER_DIVIDER * SCREEN_LENGTH
  end

  def table_divider
    puts TABLE_DIVIDER * SCREEN_LENGTH
  end

  def reveal_hands(mask = false)
    players.each do |player|
      mask_hand = mask && player.dealer?

      name = player.name
      name = MSGS['dealer'] + name if player.dealer?

      player.scoreboard.print(name)
      player.hand.print(mask_hand)
      player_divider if player != players.last
    end
  end

  def draw_table(mask = false)
    clear_screen
    reveal_hands(mask)
    table_divider
  end

  def declare_tie
    prompt(MSGS['tie'])
  end

  def declare_winner(name)
    prompt("#{name} #{MSGS['win_round']}")
  end
end
