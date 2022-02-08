require_relative '../lib/eavi/visitor'

require 'benchmark'

puts 'This benchmark compare the speed of ' \
     'a visit call and a standard method call.'
puts ''

class Page0
  def self.direct_call()
    # [...]
  end

  def direct_call()
    # [...]
  end
end
class Page1 < Page0; end
class Page2 < Page1; end
class Page3 < Page2; end

class Printer
  extend Eavi::Visitor

  def_visit Page0 do |page|
    # [...]
  end
end

class Reader
  include Eavi::Visitor

  def_visit Page0 do |page|
    # [...]
  end
end

page0 = Page0.new
page3 = Page3.new

reader = Reader.new

n = 10_000

puts 'Benchmarking…'
puts ''

standard_calls_0_when_extended = Benchmark.measure do
  n.times { Page0.direct_call }
end

standard_calls_3_when_extended = Benchmark.measure do
  n.times { Page3.direct_call }
end

visit_calls_0_when_extended = Benchmark.measure do
  n.times { Printer.visit(page0) }
end

visit_calls_3_when_extended = Benchmark.measure do
  n.times { Printer.visit(page3) }
end

standard_calls_0_when_included = Benchmark.measure do
  n.times { page0.direct_call }
end

standard_calls_3_when_included = Benchmark.measure do
  n.times { page3.direct_call }
end

visit_calls_0_when_included = Benchmark.measure do
  n.times { reader.visit(page0) }
end

visit_calls_3_when_included = Benchmark.measure do
  n.times { reader.visit(page3) }
end

speed_when_extended_at_depth_0 =
  visit_calls_0_when_extended.real / standard_calls_0_when_extended.real
speed_when_extended_at_depth_3 =
  visit_calls_3_when_extended.real / standard_calls_3_when_extended.real
speed_when_included_at_depth_0 =
  visit_calls_0_when_included.real / standard_calls_0_when_included.real
speed_when_included_at_depth_3 =
  visit_calls_3_when_included.real / standard_calls_3_when_included.real

average_at_depth_0 =
  (speed_when_extended_at_depth_0 + speed_when_included_at_depth_0) / 2
average_at_depth_3 =
  (speed_when_extended_at_depth_3 + speed_when_included_at_depth_3) / 2
average_when_included =
  (speed_when_included_at_depth_0 + speed_when_included_at_depth_3) / 2
average_when_extended =
  (speed_when_extended_at_depth_0 + speed_when_extended_at_depth_3) / 2

average = (average_when_extended + average_when_included) / 2

puts "- Average at depth 0:    #{average_at_depth_0.round(2)}x slower"
puts "- Average at depth 3:    #{average_at_depth_3.round(2)}x slower"
puts "- Average when extended: #{average_when_extended.round(2)}x slower"
puts "- Average when included: #{average_when_included.round(2)}x slower"
puts "- Global average:        #{average.round(2)}x slower"
