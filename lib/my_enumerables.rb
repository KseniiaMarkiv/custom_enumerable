module Enumerable

  def display_method __method__
    puts "\nThis is #{__method__} method"
  end
  # Your code goes here

  def my_each_with_index 
    display_method(__method__)

    return enum_for(:my_each_with_index) unless block_given?

    index = 0
    for element in self
      yield(element, index) # Yield each element to the block
      index += 1
    end
  end

  def my_select
    display_method(__method__)
    return enum_for(:my_select) unless block_given?

    result = []
    for element in self
      result << element if yield(element)
    end
    result
  end

  def my_all? pattern = nil
    display_method(__method__)

    case
    when block_given?
      for element in self
        return false unless yield(element)  # Returns false if the block returns false for any element
      end
    when pattern
      for element in self
        return false unless pattern === element  # Returns false if any element does not match the pattern
      end
    else
      for element in self
        return false if element.nil? || element == false  # Returns false if any element is nil or false
      end
    end
    true
  end

  def my_any? pattern = nil
    display_method(__method__)

    case
    when block_given?
      for element in self
        return true if yield(element)  # Returns true if the block returns true for at least one element
      end
    when pattern
      for element in self
        return true if pattern === element  # Returns true if any element matches the pattern
      end
    else
      for element in self
        return true if element  # Returns true if at least one element is truthy
      end
    end
    false
  end

  def my_none? pattern = nil
    display_method(__method__)

    case
    when block_given?
      for element in self
        return false if yield(element)  # Returns true if the block returns false for any element
      end
    when pattern
      for element in self
        return false if pattern === element  # Returns true if no element matches the pattern
      end
    else
      for element in self
        return false if element  # Returns true if all elements is nil or false
      end
    end
    true
  end

  def my_count pattern = nil
    display_method(__method__)

    count = 0

    case
    when block_given?
      for element in self
        count += 1 if yield(element)  # Count elements where the block returns true
      end
    when pattern
      for element in self
        count += 1 if pattern === element  # Count elements that match the pattern
      end
    else
      for element in self
        count += 1 if element  # Count truthy elements
      end
    end

    count
  end

  def my_map
    display_method(__method__)

    return enum_for(:my_map) unless block_given?

    result = []
    for element in self
      result << yield(element)
    end
    result
  end

  def my_inject initial = nil, sym = nil
    display_method(__method__)

    # Check if a symbol is provided as the second argument
    if sym && sym.is_a?(Symbol)
      # If initial is provided
      if initial
        memo = initial
        each do |element|
          memo = memo.send(sym, element)
        end
        return memo
      # If no initial value is provided
      else
        memo = first
        each_with_index do |element, index|
          next if index == 0
          memo = memo.send(sym, element)
        end
        return memo
      end
    # Check if a block is provided
    elsif block_given?
      memo = initial || first
      start_index = initial ? 0 : 1
      each_with_index do |element, index|
        next if index < start_index
        memo = yield(memo, element)
      end
      return memo
    else
      raise ArgumentError, "You need to provide either a block or a symbol"
    end
  end


end

# You will first have to define my_each
# on the Array class. Methods defined in
# your enumerable module will have access
# to this method
class Array
  # Define my_each here
  def my_each
    return enum_for(:my_each) unless block_given?
    for element in self
      yield(element) # Yield each element to the block
    end
  end
end

array = [1, 2, 3]
array.my_each do |element|
  puts "Current number is: #{element}"
end



selected_elements = array.my_select { |element| element > 1 }
puts "Selected elements: #{selected_elements}"

all_elements = array.my_all?(Integer)
puts "All elements: #{all_elements}"

p %w[ant bear cat].my_all? { |word| word.length >= 3 }


any_elements = array.my_any?(Integer)  
puts "Any elements: #{any_elements}"
elements = array.my_any?
puts "Any elements: #{elements}"


none_elements = array.my_none?
puts "None elements: #{none_elements}"

p %w{ant bear cat}.my_none? { |word| word.length == 5 } #=> true
p %w{ant bear cat}.my_none? { |word| word.length >= 4 } #=> false
p %w{ant bear cat}.my_none?(/d/)                        #=> true
p [1, 3.14, 42].my_none?(Float)                         #=> false
p [].my_none?                                           #=> true
p [nil].my_none?                                        #=> true
p [nil, false].my_none?                                 #=> true
p [nil, false, true].my_none?                           #=> false


p ary = [1, 2, 4, 2]
p ary.my_count               #=> 4
p ary.my_count(2)            #=> 2
p ary.my_count{ |x| x%2==0 } #=> 3

p (1..4).my_map { |i| i*i }      #=> [1, 4, 9, 16]
p (1..4).my_map { "cat"  }   #=> ["cat", "cat", "cat", "cat"]


# Sum some numbers
p (5..10).my_inject { |sum, number| sum + number }                            #=> 45
# Same using a block and inject
p (5..10).my_inject { |sum, n| sum + n }            #=> 45
# Multiply some numbers
p (5..10).my_inject(1, :*)                          #=> 151200
# Same using a block
p (5..10).my_inject(1) { |product, n| product * n } #=> 151200
# find the longest word
longest = %w{ cat sheep bear }.my_inject do |memo, word|
   memo.length > word.length ? memo : word
end
p longest                                        #=> "sheep"

['a', 'b', 'c'].my_each_with_index do |element, index|
  puts "Index #{index}: #{element}"
end

hash = Hash.new
%w(cat dog wombat).my_each_with_index { |item, index|
  hash[item] = index
}
p hash   #=> {"cat"=>0, "dog"=>1, "wombat"=>2}