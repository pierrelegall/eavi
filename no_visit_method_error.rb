class NoVisitMethodError < NoMethodError
  attr_reader :visitor, :visitable

  def initialize visitor, visitable
    @visitor   = visitor
    @visitable = visitable
  end

  def message
    "There is no method to visit #{@visitable.class} " \
    "objects in the #{@visitor.class} class"
  end
end
