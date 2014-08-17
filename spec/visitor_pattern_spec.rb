require_relative './spec_helper'

describe DesignWizard::VisitorPattern do
  before :all do
    Object.const_set :VisitorTest, Class.new
    VisitorTest.include Visitor
    String.include Visitable
    @visitor = VisitorTest.new
  end
  
  describe Visitor do
    describe '#visit' do
      context 'when visit method exists' do
        before :all do
          @visitor.class.send :define_method, :visit_String do |string|
            return String
          end
        end
        it { @visitor.respond_to?(:visit_String).should be_true }
        it { @visitor.visit(String.new).should == String }
      end
      
      context 'when visit method does not exist' do
        it 'raise NoVisitMethodError' do
          expect { @visitor.visit(Array.new) }.to raise_error NoVisitMethodError
        end
      end
    end
  end
  
  describe Visitable do
    describe '#accept' do
      # TO DO... no idea :d
    end
  end
  
  describe '#visit_method_for' do
    before do
      Object.const_set :A, Module.new
      A.const_set      :B, Module.new
      A::B.const_set   :C, Class.new
    end
    
    it { visit_method_for(String).should_not == :'visit_string' }
    it { visit_method_for(A::B::C).should_not == :'visit_C' }
    it { visit_method_for(A::B::C).should_not == :'visit_A' }
    it { visit_method_for(A::B::C).should_not == :'visit_A_B' }
    it { visit_method_for(A::B::C).should_not == :'visit_a_b_c' }
    it { visit_method_for(String).should == :'visit_String' }
    it { visit_method_for(A::B::C).should == :'visit_A_B_C' }
  end
end
