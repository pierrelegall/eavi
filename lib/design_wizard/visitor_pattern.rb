module DesignWizard
  module VisitorPattern
    module Visitor
      def visit(object, as: object.class)
        as.ancestors.each do |ancestor|
          visit_method = visit_methods[ancestor]
          unless visit_method.nil?
            return visit_method.call object
          end
        end
        raise NoVisitMethodError.new self, object, as
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
      attr_reader :visitor, :visited, :visited_as

      def initialize(visitor, visited, visited_as)
        @visitor = visitor
        @visited = visited
        @visited_as = visited_as
      end

      def message
        if @visited.class == visited_as
          "There is no method to visit #{@visited} in #{@visitor}"
        else
          "No method found to visit #{@visited} in #{@visitor} " \
          "when visited as #{visited_as}"
        end
      end
    end
  end
end
