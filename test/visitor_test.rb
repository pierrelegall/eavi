require 'minitest/autorun'

require_relative '../lib/risitor/visitor'

include Risitor

class VisitorTest < MiniTest::Test
  class Page
  end

  class Reader
    include Visitor

    when_visiting Page do
      "Reading"
    end
  end

  class Printer
    extend Visitor

    when_visiting Page do |page|
      "Printing #{page}"
    end

    when_visiting String do |string, capitalize|
      string = string.capitalize if capitalize
      return string
    end
  end

  class NewReader < Reader
  end

  class NewPrinter < Printer
  end

  def setup
    @page = Page.new
    @reader = Reader.new
    Reader.reset_visit_methods
    Printer.reset_visit_methods
  end

  def test_visit__when_included
    @reader.class.when_visiting Page do
      "Reading"
    end
    assert_equal (@reader.visit @page), "Reading"
    assert_equal (@reader.visit @page, as: Page), "Reading"

    assert_raises NoVisitMethodError do
      @reader.visit "string"
    end
    assert_raises NoVisitMethodError do
      @reader.visit "string", as: String
    end
    assert_raises NoVisitMethodError do
      @reader.visit @page, as: String
    end

    @reader.class.when_visiting Page do |page|
      self
    end
    assert_same (@reader.visit @page), @reader
  end

  def test_visit__when_extended
    Printer.when_visiting Page do |page|
      "Printing"
    end
    assert_equal (Printer.visit @page), "Printing"
    assert_equal (Printer.visit @page, as: Page), "Printing"

    assert_raises NoVisitMethodError do
      Printer.visit "string"
    end
    assert_raises NoVisitMethodError do
      Printer.visit "string", as: String
    end
    assert_raises NoVisitMethodError do
      Printer.visit @page, as: String
    end

    Printer.when_visiting Page do |page|
      self
    end
    assert_same (Printer.visit @page), Printer
  end

  def test_visit__with_args
    Printer.when_visiting String do |string, *args|
      args
    end
    assert_equal (Printer.visit "something", 1, 2), [1, 2]

    Printer.when_visiting String do |string, a, b|
      {a: a, b: b}
    end
    assert_equal (Printer.visit "something", 1, 2), {a: 1, b: 2}
  end

  def test_visit__with_inheritance
    Reader.when_visiting Page do |page|
      "Reading"
    end
    new_reader = NewReader.new
    assert_equal (new_reader.visit @page), "Reading"

    Printer.when_visiting Page do |page|
      "Printing"
    end
    assert_equal (NewPrinter.visit @page), "Printing"
  end

  def test_add_visit_methods
    Printer.when_visiting Array do |array|
      "Visiting an array"
    end
    assert_equal (Printer.visit []), "Visiting an array"
  end

  def test_remove_visit_methods
    Printer.when_visiting Page do |page|
      "Printing"
    end
    Printer.remove_visit_method Page
    assert_raises NoVisitMethodError do |page|
      Printer.visit @page
    end
  end

  def test_reset_visit_methods
    Printer.when_visiting Page do
      "Printing"
    end
    refute_empty Printer.visit_methods
    Printer.reset_visit_methods
    assert_empty Printer.visit_methods
  end
end
