require_relative '../lib/eavi/visitor'

require 'benchmark'

puts 'This benchmark compare the speed of ' \
     'a visit call and a standard method call.'
puts ''

class Page0; end
class Page1 < Page0; end
class Page2 < Page1; end
class Page3 < Page2; end

class Printer
  extend Eavi::Visitor

  visit_for Page0 do |page|
    "Printing #{page}"
  end

  def self.do_not_visit(page)
    "Printing #{page}"
  end
end

class Reader
  include Eavi::Visitor

  visit_for Page0 do |page|
    "Reading #{page}"
  end

  def do_not_visit(page)
    "Reading #{page}"
  end
end

page0 = Page0.new
page3 = Page3.new

reader = Reader.new

n = 10_000

puts 'Benchmarking…'
puts ''

standard_calls_0_when_extended = Benchmark.measure do
  n.times { Printer.do_not_visit page0 }
end

standard_calls_3_when_extended = Benchmark.measure do
  n.times { Printer.do_not_visit page3 }
end

visit_calls_0_when_extended = Benchmark.measure do
  n.times { Printer.visit page0 }
end

visit_calls_3_when_extended = Benchmark.measure do
  n.times { Printer.visit page3 }
end

standard_calls_0_when_included = Benchmark.measure do
  n.times { reader.do_not_visit page0 }
end

standard_calls_3_when_included = Benchmark.measure do
  n.times { reader.do_not_visit page3 }
end

visit_calls_0_when_included = Benchmark.measure do
  n.times { reader.visit page0 }
end

visit_calls_3_when_included = Benchmark.measure do
  n.times { reader.visit page3 }
end

speed_when_extended_at_depth0 =
  visit_calls_0_when_extended.real / standard_calls_0_when_extended.real
speed_when_extended_at_depth3 =
  visit_calls_3_when_extended.real / standard_calls_3_when_extended.real
speed_when_included_at_depth0 =
  visit_calls_0_when_included.real / standard_calls_0_when_included.real
speed_when_included_at_depth3 =
  visit_calls_3_when_included.real / standard_calls_3_when_included.real

average_at_depth0 =
  (speed_when_extended_at_depth0 + speed_when_included_at_depth0) / 2
average_at_depth3 =
  (speed_when_extended_at_depth3 + speed_when_included_at_depth3) / 2
average_when_included =
  (speed_when_included_at_depth0 + speed_when_included_at_depth3) / 2
average_when_extended =
  (speed_when_extended_at_depth0 + speed_when_extended_at_depth3) / 2

average = (average_when_extended + average_when_included) / 2

puts "Average at depth 0:    #{average_at_depth0.round(2)}x slower"
puts "Average at depth 3:    #{average_at_depth3.round(2)}x slower"
puts "Average when extended: #{average_when_extended.round(2)}x slower"
puts "Average when included: #{average_when_included.round(2)}x slower"
puts "Total average:         #{average.round(2)}x slower"
