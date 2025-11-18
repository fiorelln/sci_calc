require 'bigdecimal'
require 'bigdecimal/math'
require 'time'

class Calculator
  include BigMath

  CONSTANTS = { 'pi' => Math::PI.to_s, 'e' => Math::E.to_s }

  FUNCTIONS = {
    'sqrt'   => ->(x){ BigDecimal(x).sqrt(50) },
    'sin'    => ->(x, deg=false){ deg ? Math.sin(x.to_f * Math::PI / 180) : Math.sin(x.to_f) },
    'cos'    => ->(x, deg=false){ deg ? Math.cos(x.to_f * Math::PI / 180) : Math.cos(x.to_f) },
    'tan'    => ->(x, deg=false){ deg ? Math.tan(x.to_f * Math::PI / 180) : Math.tan(x.to_f) },
    'asin'   => ->(x, deg=false){ deg ? Math.asin(x.to_f) * 180 / Math::PI : Math.asin(x.to_f) },
    'acos'   => ->(x, deg=false){ deg ? Math.acos(x.to_f) * 180 / Math::PI : Math.acos(x.to_f) },
    'atan'   => ->(x, deg=false){ deg ? Math.atan(x.to_f) * 180 / Math::PI : Math.atan(x.to_f) },
    'sinh'   => ->(x){ Math.sinh(x.to_f) },
    'cosh'   => ->(x){ Math.cosh(x.to_f) },
    'tanh'   => ->(x){ Math.tanh(x.to_f) },
    'asinh'  => ->(x){ Math.asinh(x.to_f) },
    'acosh'  => ->(x){ Math.acosh(x.to_f) },
    'atanh'  => ->(x){ Math.atanh(x.to_f) },
    'log'    => ->(x){ Math.log10(x.to_f) },
    'ln'     => ->(x){ Math.log(x.to_f) },
    'exp'    => ->(x){ Math.exp(x.to_f) },
    'fact'   => ->(x){ (1..x.to_i).inject(1, :*) },
    'logn'   => ->(base, x){ Math.log(x.to_f)/Math.log(base.to_f) }
  }

  @degree_mode = false
  @history = []

  class << self
    attr_accessor :degree_mode, :history

    def toggle_degree
      @degree_mode = !@degree_mode
      @degree_mode ? "Switched to Degree mode" : "Switched to Radian mode"
    end

    def evaluate(expression)
      expr = expression.downcase.gsub(/\s+/, "")
      CONSTANTS.each { |k, v| expr.gsub!(k, v) }
      expr.gsub!("^", "**")

      FUNCTIONS.each do |name, func|
        expr.gsub!(/#{name}\(([^()]+?)\)/) do
          args = $1.split(',').map(&:strip)
          val = func.call(*args, @degree_mode)
          val.to_s
        end
      end

      # skip regex validation untuk kompatibilitas Ruby 3.x
      result = BigDecimal(eval(expr).to_s)
      @history << { :time => Time.now, :expression => expression, :result => result }
      result
    rescue ZeroDivisionError
      "Error: Division by zero"
    rescue => e
      "Error: #{e.message}"
    end

    def show_history
      return "No history yet" if @history.empty?
      @history.each_with_index.map do |h,i|
        "#{i+1}. [#{h[:time].strftime('%H:%M:%S')}] #{h[:expression]} = #{h[:result].to_s('F')}"
      end.join("\n")
    end
  end
end

#CLI
puts "Scientific Calculator CLI"
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
puts "Result: #{output.is_a?(BigDecimal) ? output.to_s('F') : output}"
end
puts "Goodbye!"
