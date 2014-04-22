# Author :: Pierre Le Gall (@userdir)

# Contains all necessary tools to apply the visitor pattern easily
module VisitorPattern
  # Contains helper methods for the visitor
  module VisitorHelper
    # Build the class visit method symbol
    def visit_method_for klass
      method = "visit_#{klass}".gsub(/::/, '_')
      return method.intern
    end
  end
  
  # The visitor implementation
  module Visitor
    include VisitorHelper
    
    # Method to use to visit an object
    def visit object
      visit_method = find_visit_method_for object
      send visit_method, object
    end
    
    private
    
    # Recurcive visit method finder
    def find_visit_method_for object, klass=object.class
      raise NoVisitMethodError.new self, object if klass.nil?
      visit_method = visit_method_for klass
      if self.respond_to? visit_method
        return visit_method
      else
        find_visit_method_for object, klass.superclass
      end
    end
    
    # Auto extend the class by ClassMethods
    def self.included visitor_class
      visitor_class.extend ClassMethods
    end
    
    # Auto extended module for Visitor
    module ClassMethods
      include VisitorHelper

      # Useful helper to create visit methods
      def visitor_for *classes, &block
        classes.each do |klass|
          klass.include Visitable
          define_method (visit_method_for klass), block
        end
      end
    end
  end
  
  # Module who set the class visitable by a visitor
  module Visitable
    # The accept method of the visitor pattern
    def accept visitor
      visitor.visit self
    end
  end
  
  # Error raise when visit method is not finded in the visitor
  class NoVisitMethodError < NoMethodError
    attr_reader :visitor, :visitable
    
    # Constructor
    def initialize visitor, visitable
      @visitor   = visitor
      @visitable = visitable
    end
    
    # The description message
    def message
      "There is no method to visit #{@visitable.class} " \
      "objects in the #{@visitor.class} class"
    end
  end
end
