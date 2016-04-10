# coding: utf-8
require 'minitest/autorun'

require_relative '../lib/design_wizard/visitor_pattern'

include DesignWizard::VisitorPattern

class Page
end

class Reader
  include Visitor

  when_visiting Page do |page|
    "Reading the page"
  end
end

class Printer
  extend Visitor

  when_visiting Page do |page|
    "Printing the page"
  end
end

class VisitorPatternTest < MiniTest::Test
  def setup
    @page = Page.new
    @reader = Reader.new
  end

  def after
    @page = Page.new
    @reader = Reader.new
  end
  
  def test_visit
    assert @reader.visit(@page) == "Reading the page"
    assert Printer.visit(@page) == "Printing the page"
    assert_raises NoVisitMethodError do
      @reader.visit("a string")
    end
    assert_raises NoVisitMethodError do
      Printer.visit("a string")
    end
    assert @reader.visit(@page, as: Page) == "Reading the page"
    assert Printer.visit(@page, as: Page) == "Printing the page"
    assert_raises NoVisitMethodError do
      @reader.visit "a string", as: String
    end
    assert_raises NoVisitMethodError do
      Printer.visit "a string", as: String
    end
    assert_raises NoVisitMethodError do
      @reader.visit @page, as: String
    end
    assert_raises NoVisitMethodError do
      Printer.visit @page, as: String
    end
  end

  def test_add_visit_method
    assert_raises NoMethodError do
      @reader.when_visiting Array do
        # some code…
      end
    end
    Printer.when_visiting Array do
      "Visiting an array"
    end
    assert Printer.visit([]) == "Visiting an array"
  end

  def test_remove_visit_action
    assert_raises NoMethodError do
      @reader.remove_visit_action Array do
        # some code…
      end
    end
    Printer.when_visiting Array do
      "Visiting an array"
    end
    Printer.remove_visit_action Array
    #assert_raises NoActionMethodError do
      Printer.visit([])
    #end
  end
end
