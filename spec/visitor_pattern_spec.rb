require_relative './spec_helper'

describe DesignWizard::VisitorPattern do  
  describe Visitor do
    context 'when used as singleton (extend a module)' do
      before :all do
        Object.const_set :Page, Class.new
        Object.const_set :Printer, Module.new
        Printer.extend Visitor
      end

      after :all do
        Object.send :remove_const, :Page
        Object.send :remove_const, :Printer
      end

      describe '#visit' do
        context 'when visit method exists' do
          before :all do
            Printer.when_visiting Page do |page|
              'Printing the page'
            end
          end

          it { expect(Printer.visit(Page.new)).to eq 'Printing the page' }
        end

        context 'when visit method does not exist' do
          it 'should raise NoVisitMethodError' do
            expect { Printer.visit(Array.new) }.to raise_error NoVisitMethodError
          end
        end
      end
    end

    context 'when used in instances (included in a class)' do
      before :all do
        Object.const_set :Page, Class.new
        Object.const_set :Printer, Class.new
        Printer.include Visitor
        @printer = Printer.new
      end

      describe '#visit' do
        context 'when visit method exists' do
          before :all do
            @printer.class.when_visiting Page do |page|
              'Printing the page'
            end
          end

          it { expect(@printer.visit(Page.new)).to eq 'Printing the page' }
        end

        context 'when visit method does not exist' do
          it 'raise NoVisitMethodError' do
            expect { @printer.visit(Array.new) }.to raise_error NoVisitMethodError
          end
        end
      end
    end
  end
end
