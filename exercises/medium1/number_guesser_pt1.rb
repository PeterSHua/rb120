=begin
nouns:
numbers between 1 - 100
limit

verbs:
guess

---
=end

class OutofBounds < StandardError; end

class GuessingGame
  # attr
  #   number_to_guess (between 1 to 100)

  # behaviours
  #   play


  def initialize(low_number, high_number)
    self.number_to_guess = nil
    self.range = (low_number..high_number)
    self.guess_limit = Math.log2(range.size).to_i + 1
  end

  def play
    new_number

    guess_limit.downto(1) do |attempts_left|
      remaining(attempts_left)

      user_guess = req_guess

      if correct?(user_guess)
        puts "That's the number!"
        puts
        puts "You won!"
        puts
        return
      elsif low?(user_guess)
        puts "Your guess is too low."
        puts
      elsif high?(user_guess)
        puts "Your guess is too high."
        puts
      end
    end

    lose
    puts
  end

  private

  attr_accessor :number_to_guess, :range, :guess_limit

  def remaining(attempts_left)
    unit = if attempts_left == 1
             "guess"
           else
             "guesses"
           end

    puts "You have #{attempts_left} #{unit} remaining."
  end

  def req_guess
    begin
      print "Enter a number between #{range.first} and #{range.last}: "
      guessed_number = gets.chomp.to_i

      unless range.cover?(guessed_number)
        raise OutofBounds.new("Invalid guess. ")
      end
    rescue OutofBounds => e
      print e.message
      retry
    end

    guessed_number
  end

  def correct?(guessed_number)
    guessed_number == number_to_guess
  end

  def low?(guessed_number)
    guessed_number < number_to_guess
  end

  def high?(guessed_number)
    guessed_number > number_to_guess
  end

  def new_number
    self.number_to_guess = range.to_a.sample
  end

  def lose
    puts "You have no more guesses. You lost!"
  end
end

game = GuessingGame.new(501, 1500)
game.play
game.play
game.play
game.play
