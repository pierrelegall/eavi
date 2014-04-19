require './visitable'
require './visitor'

describe Visitable do
  before :all do
    Object.const_set :VisitorTest, Class.new
    VisitorTest.include Visitor
    visitor = VisitorTest.new
    String.include Visitable
  end


  describe '#visit' do
    it 'should return true if the class is visitable' do
    end
    it 'should return false if the class is not visitable' do
    end
  end

  context 'private methods' do
    describe '::visit_method_for' do
      it 'should return the symbol of the class visit method' do
        (visitor.send :visit_method_for, String).should == :'visit_String'
        #Object.const_set :A, Module.new
        #A.const_set      :B, Module.new
        #A::B.const_set   :C, Class.new
        #(Visitor.visit_method_for A::B::C).should == :'visit_A_B_C'
      end
    end
  end
end

