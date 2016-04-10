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

  def test_visit__when_included
    @reader.class.when_visiting Page do
      "Reading"
    end
    assert_equal (@reader.visit @page), "Reading"

    assert_equal (@reader.visit @page, as: Page), "Reading"

    assert_raises NoVisitActionError do
      @reader.visit "string"
    end
    assert_raises NoVisitActionError do
      @reader.visit "string", as: String
    end
    assert_raises NoVisitActionError do
      @reader.visit @page, as: String
    end
  end

  def test_visit__when_extended
    Printer.when_visiting Page do |page|
      "Printing"
    end
    assert_equal (Printer.visit @page), "Printing"

    assert_equal (Printer.visit @page, as: Page), "Printing"

    assert_raises NoVisitActionError do
      Printer.visit "string"
    end
    assert_raises NoVisitActionError do
      Printer.visit "string", as: String
    end
    assert_raises NoVisitActionError do
      Printer.visit @page, as: String
    end
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

  def test_add_visit_action
    Printer.when_visiting Array do
      "Visiting an array"
    end
    assert_equal (Printer.visit []), "Visiting an array"
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
    Printer.when_visiting Page do
      "Printing"
    end
    Printer.remove_visit_action Page
    assert_raises NoVisitActionError do
      Printer.visit @page
    end
  end
end
