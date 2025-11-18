require_relative 'calculator'

puts "Commands: 'exit', 'history', 'mode' (toggle degree/radian)"
loop do
  print ">> "
  input = gets.chomp
  case input.downcase
  when 'exit'
    break
  when 'history'
    puts Calculator.show_history
    next
  when 'mode'
    puts Calculator.toggle_degree
    next
  end
  output = Calculator.evaluate(input)
  puts "Result: #{output.to_s('F')}"
end
puts "Goodbye!"
