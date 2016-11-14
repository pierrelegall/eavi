require 'minitest/autorun'

require_relative '../lib/risitor/visitor'
require_relative 'fixtures'

include Risitor::Fixtures

class VisitorTest < MiniTest::Test
  def setup
    @page = Page.new
    @reader = Reader.new
    Reader.reset_visit_methods
    Printer.reset_visit_methods
  end

  def test_visit__when_included
    @reader.class.when_visiting Page do
      return 'Reading'
    end
    assert_equal @reader.visit(@page),
                 'Reading'
    assert_equal @reader.visit(@page, as: Page),
                 'Reading'
    assert_raises Risitor::NoVisitMethodError do
      @reader.visit('string')
    end
    assert_raises Risitor::NoVisitMethodError do
      @reader.visit('string', as: String)
    end
    assert_raises Risitor::NoVisitMethodError do
      @reader.visit(@page, as: String)
    end

    @reader.class.when_visiting Page do |page|
      return self
    end
    assert_same @reader.visit(@page),
                @reader
  end

  def test_visit__when_extended
    Printer.when_visiting Page do |page|
      return 'Printing'
    end
    assert_equal Printer.visit(@page),
                 'Printing'
    assert_equal Printer.visit(@page, as: Page),
                 'Printing'

    assert_raises Risitor::NoVisitMethodError do
      Printer.visit('string')
    end
    assert_raises Risitor::NoVisitMethodError do
      Printer.visit('string', as: String)
    end
    assert_raises Risitor::NoVisitMethodError do
      Printer.visit(@page, as: String)
    end

    Printer.when_visiting Page do |page|
      return self
    end
    assert_same Printer.visit(@page),
                Printer
  end

  def test_visit__with_args
    Printer.when_visiting String do |string, *args|
      return args
    end
    assert_equal Printer.visit('something', 1, 2),
                 [1, 2]

    Printer.when_visiting String do |string, a, b|
      return { a: a, b: b }
    end
    assert_equal (Printer.visit 'something', 1, 2),
                 { a: 1, b: 2 }
  end

  def test_visit__with_inheritance
    Reader.when_visiting Page do |page|
      return 'Reading'
    end
    new_reader = NewReader.new
    assert_equal new_reader.visit(@page),
                 'Reading'

    Printer.when_visiting Page do |page|
      return 'Printing'
    end
    assert_equal NewPrinter.visit(@page),
                 'Printing'
  end

  def test_alias_visit_method
    Printer.when_visiting Page do
      # [...]
    end
    Printer.send(:alias_visit_method, :print)
    Printer.print(@page)

    Reader.when_visiting Page do
      # [...]
    end
    Reader.send(:alias_visit_method, :read)
    @reader.read(@page)
  end

  def test_add_visit_methods
    Printer.when_visiting Array do |array|
      return 'Visiting an array'
    end
    assert_equal Printer.visit([]),
                 'Visiting an array'
  end

  def test_remove_visit_methods
    Printer.when_visiting Page do |page|
      'Printing'
    end
    Printer.remove_visit_method(Page)
    assert_raises Risitor::NoVisitMethodError do |page|
      Printer.visit(@page)
    end
  end

  def test_reset_visit_methods
    Printer.when_visiting Page do
      'Printing'
    end
    refute_empty Printer.visit_methods
    Printer.reset_visit_methods
    assert_empty Printer.visit_methods
  end

  def test_visitable_types
    Printer.when_visiting String, Array, Hash do
      # [...]
    end
    assert_equal Printer.visitable_types,
                 [String, Array, Hash]
  end
end
