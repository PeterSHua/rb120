=begin
nouns:
stack
register
commands
mini-lang programs
error

verbs:
place
push
add
pop
sub
multiply
divide
modulus
print
=end

class MiniLangError < StandardError; end

class Minilang
  # attributes:
  #  stack (array)
  #  register (integer)

  # behaviours:
  #  parse mini-lang programs into tokens

  #  add
  #  sub
  #  mult
  #  div
  #  mod
  #  print

  # raise exceptions for invalid tokens

  VALID_TOKENS = %w(PUSH ADD SUB MULT DIV MOD POP PRINT)

  def initialize(program)
    self.stack = Stack.new
    self.register = Register.new
    self.program = program
  end

  def eval(**parameters)
    tokens = format(program, parameters).split(' ')

    tokens.each do |token|
      if number?(token)
        register.place(token.to_i)
      else
        operation(token)
      end
    end
  end

  private

  attr_accessor :stack, :register, :program

  def number?(str)
    str =~ /\A[-+]?\d+\z/
  end

  def operation(token)
    if VALID_TOKENS.include?(token)
      send(token.downcase)
    else
      raise MiniLangError.new("Invalid token: #{token}")
    end

  rescue MiniLangError => e
    puts e.message
  end

  def push
    stack.push(register.read)
  end

  def add
    register.place(stack.pop + register.read)
  end

  def sub
    register.place(register.read - stack.pop)
  end

  def mult
    register.place(stack.pop * register.read)
  end

  def div
    register.place(register.read / stack.pop)
  end

  def mod
    register.place(register.read % stack.pop)
  end

  def pop
    register.place(stack.pop)
  end

  def print
    puts register.read
  end
end

class StackError < StandardError; end

class Stack
  # attributes:
  #   array

  # behaviours:
  #  push to stack
  #  pop from stack

  #  raise exceptions for invalid stack operations
  #  popping from empty stack

  def initialize
    self.arr = Array.new
  end

  def push(value)
    arr.push(value)
  end

  def pop
    if self.arr.empty?
      raise StackError.new("Empty stack!")
    end
    arr.pop
  rescue StackError => e
    puts e.message
  end

  def read
    arr
  end

  private

  attr_accessor :arr

end

class Register
  # attributes:
  #   value

  # behaviours:
  #  place in register
  #  read from register

  def initialize
    self.value = 0
  end

  def place(value)
    self.value = value
  end

  def read
    value
  end

  private

  attr_accessor :value
end

=begin
Minilang.new('PRINT').eval
# 0

Minilang.new('5 PUSH 3 MULT PRINT').eval
# 15

Minilang.new('5 PRINT PUSH 3 PRINT ADD PRINT').eval
# 5
# 3
# 8

Minilang.new('5 PUSH 10 PRINT POP PRINT').eval
# 10
# 5

Minilang.new('5 PUSH POP POP PRINT').eval
# Empty stack!

Minilang.new('3 PUSH PUSH 7 DIV MULT PRINT ').eval
# 6

Minilang.new('4 PUSH PUSH 7 MOD MULT PRINT ').eval
# 12

Minilang.new('-3 PUSH 5 XSUB PRINT').eval
# Invalid token: XSUB

Minilang.new('-3 PUSH 5 SUB PRINT').eval
# 8

Minilang.new('6 PUSH').eval
# (nothing printed; no PRINT commands)
=end

# Further Exploration 1

CENTIGRADE_TO_FAHRENHEIT =
  '5 PUSH %<degrees_c>d PUSH 9 MULT DIV PUSH 32 ADD PRINT'
minilang = Minilang.new(CENTIGRADE_TO_FAHRENHEIT)
minilang.eval(degrees_c: 100)
# 212
minilang.eval(degrees_c: 0)
# 32
minilang.eval(degrees_c: -40)
# -40

MILES_TO_KM = '3 PUSH %<speed_miles>d PUSH 5 MULT DIV PRINT'
minilang = Minilang.new(MILES_TO_KM)
minilang.eval(speed_miles: 100)
minilang.eval(speed_miles: 0)
minilang.eval(speed_miles: 40)

TRIANGLE_AREA = '2 PUSH %<base>d PUSH %<height>d MULT DIV PRINT'
minilang = Minilang.new(TRIANGLE_AREA)
minilang.eval(base: 5, height: 6)
minilang.eval(base: 2, height: 9)


