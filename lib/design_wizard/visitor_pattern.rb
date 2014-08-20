module DesignWizard
  module VisitorPattern
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
    
    module Helper
      def visit_method_for klass
        "visit_#{klass}".gsub(/::/, '_').to_sym
      end
    end
    
    module Visitable
      def accept visitor
        visitor.visit self
      end
    end
    
    module Visitor
      include Helper
      
      def visit object, params={}
        visit_as object.class, object, params
      end
      
      def visit_as klass, object, params={}
        raise NoVisitMethodError.new self, object if klass.nil?
        visit_method = visit_method_for klass
        if self.respond_to? visit_method
          send visit_method, object
        else
          visit_as klass.superclass, object
        end
      end
      
      private
      
      def self.included visitor
        visitor.extend VisitMethodBuilderForInclusion
      end
      
      def self.extended visitor
        visitor.extend VisitMethodBuilderForExtension
      end
      
      module VisitMethodBuilderForInclusion
        include Helper
        
        def visitor_for *classes, &block
          classes.each do |klass|
            klass.include Visitable
            define_method (visit_method_for klass), block
          end
        end
      end

      module VisitMethodBuilderForExtension
        def visitor_for *classes, &block
          classes.each do |klass|
            klass.include Visitable
            define_singleton_method (visit_method_for klass), block
          end
        end
      end
    end  
  end
end
