class Banner
  def initialize(message, width = 80)
    @message = message
    @width = width ? 80 : width
  end

  def to_s
    [horizontal_rule, empty_line, message_line, empty_line, horizontal_rule].join("\n")
  end

  private

  def horizontal_rule
    "+" + "-" * (@width - 4) + "+"
  end

  def empty_line
    "|" + " " * (@width - 4) + "|"
  end

  def message_line
    "|#{@message.center(@width - 4)}|"
  end
end

banner = Banner.new('To boldly go where no one has gone before.', 50)
puts banner

banner = Banner.new('lorem ipsum', 100)
puts banner
