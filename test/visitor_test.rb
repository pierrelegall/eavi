require 'minitest/autorun'

require_relative '../lib/eavi/visitor'
require_relative 'fixtures'

include Eavi::Fixtures

class VisitorTest < MiniTest::Test
  def setup
    @page = Page.new
    @reader = Reader.new
    Reader.reset_visit_methods
    Printer.reset_visit_methods
  end

  def test_visit__when_included
    @reader.class.visit_for Page do
      return 'Reading'
    end
    assert_equal @reader.visit(@page),
                 'Reading'
    assert_equal @reader.visit(@page, as: Page),
                 'Reading'

    assert_raises Eavi::NoVisitMethodError do
      @reader.visit('string')
    end
    assert_raises Eavi::NoVisitMethodError do
      @reader.visit('string', as: String)
    end
    assert_raises Eavi::NoVisitMethodError do
      @reader.visit(@page, as: String)
    end

    assert_raises TypeError do
      @reader.visit('string')
    end
    assert_raises TypeError do
      @reader.visit('string', as: String)
    end
    assert_raises TypeError do
      @reader.visit(@page, as: String)
    end

    @reader.class.visit_for Page do
      return self
    end
    assert_same @reader.visit(@page),
                @reader

    @reader.visit_for Page do |page|
      return page
    end
    assert_same @reader.visit(@page),
                @page
  end

  def test_visit__when_extended
    Printer.visit_for Page do
      return 'Printing'
    end
    assert_equal Printer.visit(@page),
                 'Printing'
    assert_equal Printer.visit(@page, as: Page),
                 'Printing'

    assert_raises Eavi::NoVisitMethodError do
      Printer.visit('string')
    end
    assert_raises Eavi::NoVisitMethodError do
      Printer.visit('string', as: String)
    end
    assert_raises Eavi::NoVisitMethodError do
      Printer.visit(@page, as: String)
    end

    assert_raises TypeError do
      Printer.visit('string')
    end
    assert_raises TypeError do
      Printer.visit('string', as: String)
    end
    assert_raises TypeError do
      Printer.visit(@page, as: String)
    end

    Printer.visit_for Page do
      return self
    end
    assert_same Printer.visit(@page),
                Printer

    Printer.visit_for Page do |page|
      return page
    end
    assert_same Printer.visit(@page),
                @page
  end

  def test_visit__with_args
    Printer.visit_for String do |_, *args|
      return args
    end
    assert_equal Printer.visit('something', 1, 2),
                 [1, 2]

    Printer.visit_for String do |_, a, b|
      return { a: a, b: b }
    end
    assert_equal Printer.visit('something', 1, 2),
                 { a: 1, b: 2 }
  end

  def test_visit__with_inheritance
    Reader.visit_for Page do
      return 'Reading'
    end
    new_reader = NewReader.new
    assert_equal new_reader.visit(@page),
                 'Reading'

    Printer.visit_for Page do
      return 'Printing'
    end
    assert_equal NewPrinter.visit(@page),
                 'Printing'
  end

  def test_alias_visit
    Printer.visit_for Page do
      # [...]
    end
    Printer.send(:alias_visit, :print)
    assert_respond_to Printer, :print, @page

    Reader.visit_for Page do
      # [...]
    end
    Reader.send(:alias_visit, :read)
    assert_respond_to @reader, :read, @page
  end

  def test_add_visit_methods
    Printer.visit_for Array do
      return 'Visiting an array'
    end
    assert_equal Printer.visit([]),
                 'Visiting an array'
  end

  def test_remove_visit_methods
    Printer.visit_for Page do
      'Printing'
    end
    Printer.remove_visit_method(Page)
    assert_raises Eavi::NoVisitMethodError do
      Printer.visit(@page)
    end
  end

  def test_reset_visit_methods
    Printer.visit_for Page do
      'Printing'
    end
    refute_empty Printer.visit_methods
    Printer.reset_visit_methods
    assert_empty Printer.visit_methods
  end

  def test_visit_methods
    Printer.visit_for String, Array, Hash do
      # [...]
    end
    Printer.visit_methods.each do |method|
      assert_respond_to Printer, method
    end
  end

  def test_visitable_types
    Printer.visit_for String, Array, Hash do
      # [...]
    end
    assert_equal Printer.visitable_types,
                 [String, Array, Hash]
  end
end
