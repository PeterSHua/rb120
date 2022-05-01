module Console
  require 'yaml'

  MSGS = YAML.load_file('twenty_one.yml')

  # Enforces the user to enter an input that matches a regex in a given regex
  # array. Returns the regex that matched.
  def req_from_rgx_list(msg, rgx_arr)
    prompt(msg)

    loop do
      user_input = gets.chomp

      return if rgx_arr.empty?

      rgx_arr.each do |rgx|
        return rgx if user_input =~ rgx
      end

      prompt(MSGS['invalid_choice'])
    end
  end

  # Returns true when the input from the user matches true_rgx.
  # Returns false when the input from the user matches false_rgx.
  def bool_choice(msg, true_rgx, false_rgx)
    rgx = req_from_rgx_list(msg, [true_rgx, false_rgx])

    if rgx == true_rgx
      true
    elsif rgx == false_rgx
      false
    end
  end

  def wait_user
    msg = MSGS['wait_user']
    req_from_rgx_list(msg, [])
  end

  def prompt(msg)
    puts "=> #{msg}"
  end

  def clear_screen
    system 'clear'
  end

  # Returns a formatted string from array items seperated by a deliminator
  # and ending with a grammar conjugation.
  # The formatted string has no deliminator if the array has only 2 items.
  # For example:
  #   joinor([1, 2, 3, 4])
  #     => 1, 2, 3, or 4
  #   joinor([1, 2])
  #     => 1 or 2
  def joinor(arr, delim = ', ', last = 'or')
    case arr.size
    when 0 then return ''
    when 1 then return arr.first.to_s
    when 2 then delim = ' '
    end

    "#{arr[0..-2].join(delim)}#{delim}#{last} #{arr.last}"
  end
end
