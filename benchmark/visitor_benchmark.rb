require_relative '../lib/risitor/visitor'

require 'benchmark'

puts "This benchmark compare the speed of " \
     "a visit call and a standard method call."
puts ""

class Page0; end
class Page1 < Page0; end
class Page2 < Page1; end
class Page3 < Page2; end
class Page4 < Page3; end
class Page5 < Page4; end

class Printer
  extend Risitor::Base

  when_visiting Page0 do |page|
    "Printing #{page}"
  end

  def self.do_not_visit(page)
    "Printing #{page}"
  end
end

class Reader
  include Risitor::Base

  when_visiting Page0 do |page|
    "Reading #{page}"
  end

  def do_not_visit(page)
    "Reading #{page}"
  end
end

page0 = Page0.new
page5 = Page5.new

reader = Reader.new

n = 10_000

puts "Benchmarking…"
puts ""

standard_calls_0_when_extended = Benchmark.measure do
  n.times { Printer.do_not_visit page0 }
end

standard_calls_5_when_extended = Benchmark.measure do
  n.times { Printer.do_not_visit page5 }
end

visit_calls_0_when_extended = Benchmark.measure do
  n.times { Printer.visit page0 }
end

visit_calls_5_when_extended = Benchmark.measure do
  n.times { Printer.visit page5 }
end

standard_calls_0_when_included = Benchmark.measure do
  n.times { reader.do_not_visit page0 }
end

standard_calls_5_when_included = Benchmark.measure do
  n.times { reader.do_not_visit page5 }
end

visit_calls_0_when_included = Benchmark.measure do
  n.times { reader.visit page0 }
end

visit_calls_5_when_included = Benchmark.measure do
  n.times { reader.visit page5 }
end

speed_0_when_extended =
  visit_calls_0_when_extended.real / standard_calls_0_when_extended.real

speed_5_when_extended =
  visit_calls_5_when_extended.real / standard_calls_5_when_extended.real

speed_0_when_included =
  visit_calls_0_when_included.real / standard_calls_0_when_included.real

speed_5_when_included =
  visit_calls_5_when_included.real / standard_calls_5_when_included.real

average_at_depth_0 = (speed_0_when_extended + speed_0_when_included) / 2
average_at_depth_5 = (speed_5_when_extended + speed_5_when_included) / 2
average_when_included = (speed_0_when_included + speed_5_when_included) / 2
average_when_extended = (speed_0_when_extended + speed_5_when_extended) / 2
average_when_included = (speed_0_when_included + speed_5_when_included) / 2
average = (average_when_extended + average_when_included) / 2

puts "Average at depth 0:    #{average_at_depth_0.round(2)}x slower"
puts "Average at depth 5:    #{average_at_depth_5.round(2)}x slower"
puts "Average when extended: #{average_when_extended.round(2)}x slower"
puts "Average when included: #{average_when_included.round(2)}x slower"
puts "Total average:         #{average.round(2)}x slower"
