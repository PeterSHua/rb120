require_relative 'deck_of_cards'
require 'pry-byebug'

class PokerHand
  ROYALS = Card::FACES.keys << 10
  HAND_RANK = [
    'High card',
    'Pair',
    'Two pair',
    'Three of a kind',
    'Straight',
    'Flush',
    'Full house',
    'Four of a kind',
    'Straight flush',
    'Royal flush'
  ]

  def initialize(hand)
    self.hand = hand
  end

  def print
    hand.each do |card|
      puts card
    end
  end

  def best_hand(cards)
    case
    when royal_flush?(cards)     then 'Royal flush'
    when straight_flush?(cards)  then 'Straight flush'
    when four_of_a_kind?(cards)  then 'Four of a kind'
    when full_house?(cards)      then 'Full house'
    when flush?(cards)           then 'Flush'
    when straight?(cards)        then 'Straight'
    when three_of_a_kind?(cards) then 'Three of a kind'
    when two_pair?(cards)        then 'Two pair'
    when pair?(cards)            then 'Pair'
    else                       'High card'
    end
  end

  def evaluate
    possible_hands.max_by do |cards|
      HAND_RANK.index(best_hand(cards))
    end
  end

  def >(other)
    HAND_RANK.index(evaluate) > HAND_RANK.index(other.evaluate)
  end

  def <(other)
    HAND_RANK.index(evaluate) < HAND_RANK.index(other.evaluate)
  end

  def ==(other)
    evaluate == other.evaluate
  end

  def possible_hands
    result = []

    (0...hand.length).each do |first_idx|
      (first_idx...hand.length).each do |second_idx|
        result << hand[0...first_idx] +
                  hand[(first_idx + 1)...second_idx] +
                  hand[(second_idx + 1)...hand.length]
      end
    end

    result
  end

  private

  attr_accessor :hand


  def royal_flush?(cards)
    cards.all? { |card| ROYALS.include?(card.rank)} &&
      cards.all? { |card| card.suit == 'Hearts' }
  end

  def straight_flush?(cards)
    straight?(cards) && flush?(cards)
  end

  def x_of_a_kind?(x, cards)
    cards.any? do |test_card|
      cards.count { |card| test_card.value == card.value } == x
    end
  end

  def four_of_a_kind?(cards)
    x_of_a_kind?(4, cards)
  end

  def full_house?(cards)
    x_of_a_kind?(3, cards) && x_of_a_kind?(2, cards)
  end

  def flush?(cards)
    cards.all? { |card| card.suit == cards.first.suit }
  end

  def straight?(cards)
    flush_start = cards.min_by(&:value).value
    flush_finish = cards.max_by(&:value).value

    (flush_start..flush_finish).to_a == cards.map(&:value).sort
  end

  def three_of_a_kind?(cards)
    x_of_a_kind?(3, cards)
  end

  def two_pair?(cards)
    uniq_value_cards = cards.uniq do |card|
      card.value
    end

    cards_with_count_2 = uniq_value_cards.select do |uniq_value_card|
      cards.count { |card| uniq_value_card.value == card.value } == 2
    end

    cards_with_count_2.size == 2
  end

  def pair?(cards)
    x_of_a_kind?(2, cards)
  end


end

# hand = PokerHand.new([
#   Card.new(10,      'Hearts'),
#   Card.new('Ace',   'Hearts'),
#   Card.new('Queen', 'Hearts'),
#   Card.new('King',  'Hearts'),
#   Card.new('Jack',  'Hearts')
# ])
# puts hand.evaluate == 'Royal flush'

# hand = PokerHand.new([
#   Card.new(8,       'Clubs'),
#   Card.new(9,       'Clubs'),
#   Card.new('Queen', 'Clubs'),
#   Card.new(10,      'Clubs'),
#   Card.new('Jack',  'Clubs')
# ])
# puts hand.evaluate == 'Straight flush'

# hand = PokerHand.new([
#   Card.new(3, 'Hearts'),
#   Card.new(3, 'Clubs'),
#   Card.new(5, 'Diamonds'),
#   Card.new(3, 'Spades'),
#   Card.new(3, 'Diamonds')
# ])
# puts hand.evaluate == 'Four of a kind'

# hand = PokerHand.new([
#   Card.new(3, 'Hearts'),
#   Card.new(3, 'Clubs'),
#   Card.new(5, 'Diamonds'),
#   Card.new(3, 'Spades'),
#   Card.new(5, 'Hearts')
# ])
# puts hand.evaluate == 'Full house'

# hand = PokerHand.new([
#   Card.new(10, 'Hearts'),
#   Card.new('Ace', 'Hearts'),
#   Card.new(2, 'Hearts'),
#   Card.new('King', 'Hearts'),
#   Card.new(3, 'Hearts')
# ])
# puts hand.evaluate == 'Flush'

# hand = PokerHand.new([
#   Card.new(8,      'Clubs'),
#   Card.new(9,      'Diamonds'),
#   Card.new(10,     'Clubs'),
#   Card.new(7,      'Hearts'),
#   Card.new('Jack', 'Clubs')
# ])
# puts hand.evaluate == 'Straight'

# hand = PokerHand.new([
#   Card.new('Queen', 'Clubs'),
#   Card.new('King',  'Diamonds'),
#   Card.new(10,      'Clubs'),
#   Card.new('Ace',   'Hearts'),
#   Card.new('Jack',  'Clubs')
# ])
# puts hand.evaluate == 'Straight'

# hand = PokerHand.new([
#   Card.new(3, 'Hearts'),
#   Card.new(3, 'Clubs'),
#   Card.new(5, 'Diamonds'),
#   Card.new(3, 'Spades'),
#   Card.new(6, 'Diamonds')
# ])
# puts hand.evaluate == 'Three of a kind'

# hand = PokerHand.new([
#   Card.new(9, 'Hearts'),
#   Card.new(9, 'Clubs'),
#   Card.new(5, 'Diamonds'),
#   Card.new(8, 'Spades'),
#   Card.new(5, 'Hearts')
# ])
# puts hand.evaluate == 'Two pair'

# hand = PokerHand.new([
#   Card.new(2, 'Hearts'),
#   Card.new(9, 'Clubs'),
#   Card.new(5, 'Diamonds'),
#   Card.new(9, 'Spades'),
#   Card.new(3, 'Diamonds')
# ])
# puts hand.evaluate == 'Pair'

# hand = PokerHand.new([
#   Card.new(2,      'Hearts'),
#   Card.new('King', 'Clubs'),
#   Card.new(5,      'Diamonds'),
#   Card.new(9,      'Spades'),
#   Card.new(3,      'Diamonds')
# ])
# puts hand.evaluate == 'High card'

# Further Exploration

# royal_flush = PokerHand.new([
#   Card.new(10,      'Hearts'),
#   Card.new('Ace',   'Hearts'),
#   Card.new('Queen', 'Hearts'),
#   Card.new('King',  'Hearts'),
#   Card.new('Jack',  'Hearts')
# ])

# straight_flush = PokerHand.new([
#   Card.new(8,       'Clubs'),
#   Card.new(9,       'Clubs'),
#   Card.new('Queen', 'Clubs'),
#   Card.new(10,      'Clubs'),
#   Card.new('Jack',  'Clubs')
# ])

# four_of_a_kind = PokerHand.new([
#   Card.new(3, 'Hearts'),
#   Card.new(3, 'Clubs'),
#   Card.new(5, 'Diamonds'),
#   Card.new(3, 'Spades'),
#   Card.new(3, 'Diamonds')
# ])

# puts royal_flush > straight_flush == true
# puts royal_flush < straight_flush == false
# puts royal_flush > four_of_a_kind == true
# puts royal_flush < straight_flush == false

hand = PokerHand.new([
  Card.new(3, 'Spades'),
  Card.new(10, 'Hearts'),
  Card.new('Ace', 'Hearts'),
  Card.new(3, 'Diamonds'),
  Card.new('King', 'Hearts'),
  Card.new('Jack', 'Hearts'),
  Card.new('Queen', 'Hearts'),
])

puts hand.evaluate
