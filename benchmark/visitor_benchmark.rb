require_relative '../lib/risitor/visitor'

include Risitor

class Reader
  include Visitor

  when_visiting String do |string|
    "Reading #{string}"
  end
end

class Printer
  extend Visitor

  when_visiting String do |string|
    "Printing #{string}"
  end
end

class NewReader < Reader; end
class NewNewReader < NewReader; end
class NewPrinter < Printer; end
class NewNewPrinter < NewPrinter; end

reader = Reader.new
new_reader = NewReader.new
new_new_reader = NewNewReader.new
page = "a page"

require 'benchmark'

n = 100_000

Benchmark.bm(7) do |bm|
  bm.report "Ext. 0:" do
    n.times do
      Printer.visit page
    end
  end
  bm.report "Ext. 1:" do
    n.times do
      NewPrinter.visit page
    end
  end
  bm.report "Ext. 2:" do
    n.times do
      NewNewPrinter.visit page
    end
  end
  bm.report "Inc. 0:" do
    n.times do
      reader.visit page
    end
  end
  bm.report "Inc. 1:" do
    n.times do
      new_reader.visit page
    end
  end
  bm.report "Inc. 2:" do
    n.times do
      new_new_reader.visit page
    end
  end
end
