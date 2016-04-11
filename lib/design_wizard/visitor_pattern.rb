module DesignWizard
  module VisitorPattern
    module Visitor
      def visit(object, *args, as: object.class)
        as.ancestors.each do |ancestor|
          visit_action = visit_actions[ancestor]
          unless visit_action.nil?
            return instance_exec(object, *args, &visit_action)
          end
        end
        raise NoVisitActionError.new self, object, as
      end

      private

      def visit_actions
        self.class.visit_actions
      end

      class << self
        def initialize(visitor)
          visitor.extend ClassMethods
          visitor.reset_visit_actions
        end

        def included(visitor)
          initialize visitor
        end

        def extended(visitor)
          initialize visitor
        end
      end

      module ClassMethods
        def visit_actions
          @visit_actions
        end

        def reset_visit_actions
          @visit_actions = {}
        end

        def add_visit_action(*classes, &block)
          classes.each do |klass|
            visit_actions[klass] = block
          end
        end

        def remove_visit_action(*classes, &block)
          classes.each do |klass|
            visit_actions.delete klass
          end
        end

        alias_method :when_visiting, :add_visit_action
      end
    end

    class NoVisitActionError < NoMethodError
      attr_reader :visitor, :visited, :visited_as

      def initialize(visitor, visited, visited_as)
        @visitor = visitor
        @visited = visited
        @visited_as = visited_as
      end

      def message
        "no action to visit an instance of #{@visited_as} in #{@visitor}"
      end
    end
  end
end
