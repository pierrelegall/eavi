require './visitable'
require './visitor'

describe Visitor do
  before :all do
    Object.const_set :VisitorTest, Class.new
    VisitorTest.include Visitor
    String.include Visitable
    @visitor = VisitorTest.new
  end
  
  describe '#visit_method_for' do
    before :all do
      Object.const_set :A, Module.new
      A.const_set      :B, Module.new
      A::B.const_set   :C, Class.new
    end
    
    it { @visitor.send(:visit_method_for, String).should == :'visit_String' }
    it { @visitor.send(:visit_method_for, A::B::C).should == :'visit_A_B_C' }
    it { @visitor.send(:visit_method_for, String).should_not == :'visit_string' }
    it { @visitor.send(:visit_method_for, A::B::C).should_not == :'visit_C' }
    it { @visitor.send(:visit_method_for, A::B::C).should_not == :'visit_A' }
    it { @visitor.send(:visit_method_for, A::B::C).should_not == :'visit_A_B' }
    it { @visitor.send(:visit_method_for, A::B::C).should_not == :'visit_a_b_c' }
  end
  
  describe '#visit' do
    context 'when visit method exists' do
      before :all do
        @visitor.class.send :define_method, :visit_String do |string|
          return String
        end
      end
      it { (@visitor.respond_to? :visit_String).should be_true }
      it { @visitor.visit(String.new).should == String }
    end

    context 'when visit method does not exist' do
      it 'raise NoVisitMethodError' do
        expect { @visitor.visit(Array.new) }.to raise_error NoVisitMethodError
      end
    end
  end
end

