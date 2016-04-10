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
  end

  def test_visit_as
    assert @reader.visit_as(Page, @page) == "Reading the page"
    assert Printer.visit_as(Page, @page) == "Printing the page"
    assert_raises NoVisitMethodError do
      @reader.visit_as(String, "a string")
    end
    assert_raises NoVisitMethodError do
      Printer.visit_as(String, "a string")
    end
    assert_raises NoVisitMethodError do
      @reader.visit_as(String, @page)
    end
    assert_raises NoVisitMethodError do
      Printer.visit_as(String, @page)
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

  def test_remove_visit_method
    assert_raises NoMethodError do
      @reader.remove_visit_method Array do
        # some code…
      end
    end
    Printer.when_visiting Array do
      "Visiting an array"
    end
    Printer.remove_visit_method Array
    assert_raises NoVisitMethodError do
      Printer.visit([])
    end
  end
end

# describe DesignWizard::VisitorPattern do
#   describe Visitor do
#     context 'when used as singleton (extend a module)' do
#       before :all do
#         Object.const_set :Page, Class.new
#         Object.const_set :Printer, Module.new
#         Printer.extend Visitor
#       end

#       after :all do
#         Object.send :remove_const, :Page
#         Object.send :remove_const, :Printer
#       end

#       describe '#visit' do
#         context 'when visit method exists' do
#           before :all do
#             Printer.when_visiting Page do |page|
#               'Printing the page'
#             end
#           end

#           it { expect(Printer.visit(Page.new)).to eq 'Printing the page' }
#         end

#         context 'when visit method does not exist' do
#           it 'should raise NoVisitMethodError' do
#             expect { Printer.visit(Array.new) }.to raise_error NoVisitMethodError
#           end
#         end
#       end
#     end

#     context 'when used in instances (included in a class)' do
#       before :all do
#         Object.const_set :Page, Class.new
#         Object.const_set :Printer, Class.new
#         Printer.include Visitor
#         @printer = Printer.new
#       end

#       describe '#visit' do
#         context 'when visit method exists' do
#           before :all do
#             @printer.class.when_visiting Page do |page|
#               'Printing the page'
#             end
#           end

#           it { expect(@printer.visit(Page.new)).to eq 'Printing the page' }
#         end

#         context 'when visit method does not exist' do
#           it 'raise NoVisitMethodError' do
#             expect { @printer.visit(Array.new) }.to raise_error NoVisitMethodError
#           end
#         end
#       end
#     end
#   end
# end
