require 'minitest/autorun'

require_relative '../lib/design_wizard/visitor_pattern'

include DesignWizard::VisitorPattern

class VisitorTest < MiniTest::Test
  class Page
  end

  class Reader
    include Visitor
  end

  module Printer
    extend Visitor
  end

  def setup
    @page = Page.new
    @reader = Reader.new
    Reader.reset_visit_actions
    Printer.reset_visit_actions
  end

  def test_visit
    @reader.class.when_visiting Page do
      "Reading the page"
    end
    assert_equal (@reader.visit @page),
                 "Reading the page"
    Printer.when_visiting Page do |page|
      "Printing the page"
    end
    assert_equal (Printer.visit @page),
                 "Printing the page"
    assert_raises NoVisitActionError do
      @reader.visit "a string"
    end
    assert_raises NoVisitActionError do
      Printer.visit "a string"
    end
    assert_equal (@reader.visit @page, as: Page),
                 "Reading the page"
    assert_equal (Printer.visit @page, as: Page),
                 "Printing the page"
    assert_raises NoVisitActionError do
      @reader.visit "a string", as: String
    end
    assert_raises NoVisitActionError do
      Printer.visit "a string", as: String
    end
    assert_raises NoVisitActionError do
      @reader.visit @page, as: String
    end
    assert_raises NoVisitActionError do
      Printer.visit @page, as: String
    end
  end

  def test_visit_with_args
    Printer.when_visiting String do |string, *args|
      args
    end
    assert_equal (Printer.visit"something", 1, 2),
                 [1, 2]
    Printer.when_visiting String do |string, a, b|
      {a: a, b: b}
    end
    assert_equal (Printer.visit "something", 1, 2),
                 {a: 1, b: 2}
  end

  def test_add_visit_action
    Printer.when_visiting Array do
      "Visiting an array"
    end
    assert_equal (Printer.visit []),
                 "Visiting an array"
  end

  def test_reset_visit_actions
    Printer.when_visiting Page do
      "Printing"
    end
    refute Printer.visit_actions.empty?
    Printer.reset_visit_actions
    assert Printer.visit_actions.empty?
  end

  def test_remove_visit_action
    Printer.when_visiting Array do
      "Visiting an array"
    end
    Printer.remove_visit_action Array
    assert_raises NoVisitActionError do
      Printer.visit []
    end
  end
end
