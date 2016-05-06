require_relative '../lib/risitor/visitor'

require 'benchmark'

include Risitor

puts "This benchmark compare the speed of " \
     "a visit call and a standard method call."
puts ""

class Page0; end
class Page1 < Page0; end
class Page2 < Page1; end
class Page3 < Page2; end
class Page4 < Page3; end
class Page5 < Page4; end
class Page6 < Page5; end
class Page7 < Page6; end
class Page8 < Page7; end
class Page9 < Page8; end

class Printer
  extend Visitor

  when_visiting Page0 do |page|
    "Printing #{page}"
  end

  def self.do_not_visit(page)
    "Printing #{page}"
  end
end

class Reader
  include Visitor

  when_visiting Page0 do |page|
    "Reading #{page}"
  end

  def do_not_visit(page)
    "Reading #{page}"
  end
end

page0 = Page0.new
page9 = Page9.new

reader = Reader.new

n = 10_000

puts "Benchmarking…"
puts ""

standard_calls_0_when_extended = Benchmark.measure do
  n.times { Printer.do_not_visit page0 }
end

standard_calls_9_when_extended = Benchmark.measure do
  n.times { Printer.do_not_visit page9 }
end

visit_calls_0_when_extended = Benchmark.measure do
  n.times { Printer.visit page0 }
end

visit_calls_9_when_extended = Benchmark.measure do
  n.times { Printer.visit page9 }
end

standard_calls_0_when_included = Benchmark.measure do
  n.times { reader.do_not_visit page0 }
end

standard_calls_9_when_included = Benchmark.measure do
  n.times { reader.do_not_visit page9 }
end

visit_calls_0_when_included = Benchmark.measure do
  n.times { reader.visit page0 }
end

visit_calls_9_when_included = Benchmark.measure do
  n.times { reader.visit page9 }
end

speed_0_when_extended =
  visit_calls_0_when_extended.real / standard_calls_0_when_extended.real

speed_9_when_extended =
  visit_calls_9_when_extended.real / standard_calls_9_when_extended.real

speed_0_when_included =
  visit_calls_0_when_included.real / standard_calls_0_when_included.real

speed_9_when_included =
  visit_calls_9_when_included.real / standard_calls_9_when_included.real

average_at_depth_0 = (speed_0_when_extended + speed_0_when_included) / 2
average_at_depth_9 = (speed_9_when_extended + speed_9_when_included) / 2
average_when_included = (speed_0_when_included + speed_9_when_included) / 2
average_when_extended = (speed_0_when_extended + speed_9_when_extended) / 2
average_when_included = (speed_0_when_included + speed_9_when_included) / 2
average = (average_when_extended + average_when_included) / 2

puts "Average at depth 0:    #{average_at_depth_0.round(2)}x slower"
puts "Average at depth 9:    #{average_at_depth_9.round(2)}x slower"
puts "Average when extended: #{average_when_extended.round(2)}x slower"
puts "Average when included: #{average_when_included.round(2)}x slower"
puts "Total average:         #{average.round(2)}x slower"