require './visitable'
require './no_visit_method_error'

module Visitor
  def visit object, klass=object.class
    visit_method = visit_method_for klass
    if self.respond_to? visit_method
      send visit_method, object
    else
      raise NoVisitMethodError.new self, object if klass.nil?
      visit object, klass.superclass
    end
  end
  
  private

  def visit_method_for klass
    method = "visit_#{klass}".gsub(/::/, '_')
    return method.intern
  end
end

