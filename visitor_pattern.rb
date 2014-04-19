# require './visitable'
# require './no_visit_method_error'

module VisitorPattern
  module Visitor
    def visit object, klass=object.class
      raise NoVisitMethodError.new self, object if klass.nil?
      method = visit_method_for klass
      if self.respond_to? method
        send method, object
      else
        visit object, klass.superclass
      end
    end
    
    def self.included visitor
      visitor.extend VisitMethodDefiner
    end
    
    module VisitMethodDefiner
      def visitor_for *classes, &block
        classes.each do |klass|
          klass.include Visitable
          define_method (visit_method_for klass), block
        end
      end
    end
  end
  
  module Visitable
    def accept visitor
      visitor.visit self
    end
  end
  
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
  
  def visit_method_for klass
    method = "visit_#{klass}".gsub(/::/, '_')
    return method.intern
  end
end

