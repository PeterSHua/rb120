class Pet
  attr_reader :type, :name

  def initialize(type, name)
    self.type = type
    self.name = name
  end

  def to_s
    "a #{type} named #{name}"
  end

  private

  attr_writer :type, :name
end

class Owner
  attr_reader :name, :pets

  def initialize(name)
    self.name = name
    self.pets = Array.new
  end

  def <<(pet)
    self.pets << pet
  end

  def number_of_pets
    pets.length
  end

  def print_pets
    puts pets
  end

  private

  attr_writer :name, :pets
end

class Shelter
  attr_accessor :owners, :unadopted

  def initialize
    self.owners = []
    self.unadopted = []
  end

  def add_pet(pet)
    self.unadopted << pet
  end

  def print_unadopted
    puts "The Animal Shelter has the following unadopted pets:"
    puts unadopted
  end

  def number_of_unadopted
    self.unadopted.length
  end

  def adopt(owner, pet)
    owner << pet
    self.owners << owner unless self.owners.include?(owner)
    unadopted.delete(pet)
  end

  def print_adoptions
    owners.each do |owner|
      puts "#{owner.name} has adopted the following pets:"
      owner.print_pets
      puts
    end

    puts
  end
end


butterscotch = Pet.new('cat', 'Butterscotch')
pudding      = Pet.new('cat', 'Pudding')
darwin       = Pet.new('bearded dragon', 'Darwin')
kennedy      = Pet.new('dog', 'Kennedy')
sweetie      = Pet.new('parakeet', 'Sweetie Pie')
molly        = Pet.new('dog', 'Molly')
chester      = Pet.new('fish', 'Chester')

phanson = Owner.new('P Hanson')
bholmes = Owner.new('B Holmes')

shelter = Shelter.new

shelter.adopt(phanson, butterscotch)
shelter.adopt(phanson, pudding)
shelter.adopt(phanson, darwin)
shelter.adopt(bholmes, kennedy)
shelter.adopt(bholmes, sweetie)
shelter.adopt(bholmes, molly)
shelter.adopt(bholmes, chester)
shelter.print_adoptions
puts "#{phanson.name} has #{phanson.number_of_pets} adopted pets."
puts "#{bholmes.name} has #{bholmes.number_of_pets} adopted pets."

asta = Pet.new('dog', 'Asta')
laddie = Pet.new('dog', 'laddie')
fluffy = Pet.new('cat', 'fluffy')
kat = Pet.new('cat', 'kat')
ben = Pet.new('cat', 'ben')
chatterbox = Pet.new('parakeet', 'chatterbox')
bluebell = Pet.new('parakeet', 'bluebell')

shelter.add_pet(asta)
shelter.add_pet(laddie)
shelter.add_pet(fluffy)
shelter.add_pet(kat)
shelter.add_pet(ben)
shelter.add_pet(chatterbox)
shelter.add_pet(bluebell)

puts

shelter.print_unadopted

puts "The Animal shelter has #{shelter.number_of_unadopted} unadopted pets."
