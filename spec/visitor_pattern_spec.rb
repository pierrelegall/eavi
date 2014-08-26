require_relative './spec_helper'

describe DesignWizard::VisitorPattern do  
  describe Visitable do
    before :all do
      Object.const_set :Doritos, Class.new
      Doritos.include Visitable
      @doritos = Doritos.new
    end
    
    it 'should respond to #accept' do
      expect(@doritos.respond_to?(:accept)).to be true
    end
  end
  
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
            Printer.visitor_for Page do |page|
              'Printing the page'
            end
          end
          
          it { expect(Printer.respond_to?(:visit_Page)).to be true }
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
            @printer.class.visitor_for Page do |page|
              'Printing the page'
            end
          end
          
          it { expect(@printer.respond_to?(:visit_Page)).to be true }
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

  describe '#visit_method_for(String)' do
    before :all do
      @result = visit_method_for String
    end
    
    it { expect(@result).to_not eq :'visit' }
    it { expect(@result).to_not eq :'visit_string' }
    it { expect(@result).to     eq :'visit_String' }
  end
  
  describe '#visit_method_for(A::B::C)' do
    before :all do
      Object.const_set :A, Module.new
      A.const_set      :B, Module.new
      A::B.const_set   :C, Class.new
      @result = visit_method_for A::B::C
    end
    
    it { expect(@result).to_not eq :'visit_C' }
    it { expect(@result).to_not eq :'visit_A' }
    it { expect(@result).to_not eq :'visit_A_B' }
    it { expect(@result).to_not eq :'visit_a_b_c' }
    it { expect(@result).to     eq :'visit_A_B_C' }
  end
end
