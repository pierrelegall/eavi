module DesignWizard
  module VisitorPattern
    module Visitor
      def visit(object)
        visit_as object.class, object
      end

      def visit_as(klass, object)
        raise NoVisitMethodError.new self, object if klass.nil?
        visit_method = visit_methods[klass]
        return visit_method.call object unless visit_method.nil?
        visit_as klass.superclass, object
      end

      private

      def visit_methods
        self.class.visit_methods
      end

      def self.included(visitor)
        visitor.extend ClassMethods
      end

      def self.extended(visitor)
        visitor.extend ClassMethods
      end

      module ClassMethods
        def visit_methods
          return @visit_methods ||= {}
        end

        def add_visit_method(*classes, &block)
          classes.each do |klass|
            visit_methods[klass] = block
          end
        end

        def remove_visit_method(*classes, &block)
          classes.each do |klass|
            visit_methods.delete klass
          end
        end

        alias_method :when_visiting, :add_visit_method
      end
    end

    class NoVisitMethodError < NoMethodError
      attr_reader :visitor, :visited

      def initialize(visitor, visited)
        @visitor = visitor
        @visitable = visited
      end

      def message
        "There is no method to visit #{@visited} in #{@visitor}"
      end
    end
  end
end
