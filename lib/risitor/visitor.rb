module Risitor
  module Visitor
    def visit(object, *args, as: object.class)
      as.ancestors.each do |ancestor|
        visit_method = VisitMethodHelper.gen_name(ancestor)
        if respond_to? visit_method
          return send(visit_method, object, *args)
        end
      end
      raise NoVisitMethodError.new(self, object, as)
    end

    private

    module ClassMethods
      def add_visit_method(*classes, &block)
        block = block.curry(1) if block.arity == 0
        classes.each do |klass|
          define_visit_method_for klass, &block
        end
      end

      def remove_visit_method(*classes)
        classes.each do |klass|
          undefine_visit_method_for klass
        end
      end

      def reset_visit_methods
        visit_methods.each do |visit_method|
          undefine_visit_method visit_method
        end
      end

      def visit_methods
        return methods.select do |method|
          VisitMethodHelper.match method
        end
      end

      alias_method :when_visiting, :add_visit_method
    end

    module ClassMethodsWhenIncluded
      private

      def define_visit_method_for(klass, &block)
        define_method VisitMethodHelper.gen_name(klass), block
      end

      def undefine_visit_method_for(klass)
        remove_method VisitMethodHelper.gen_name(klass)
      end

      def undefine_visit_method(visit_method)
        remove_method visit_method
      end
    end

    module ClassMethodsWhenExtended
      private

      def define_visit_method_for(klass, &block)
        define_singleton_method VisitMethodHelper.gen_name(klass), block
      end

      def undefine_visit_method_for(klass)
        self.singleton_class.send :remove_method, VisitMethodHelper.gen_name(klass)
      end

      def undefine_visit_method(visit_method)
        self.singleton_class.send :remove_method, visit_method
      end
    end

    class << self
      def included(visitor)
        visitor.extend ClassMethods
        visitor.extend ClassMethodsWhenIncluded
      end

      def extended(visitor)
        visitor.extend ClassMethods
        visitor.extend ClassMethodsWhenExtended
      end
    end
  end

  module VisitMethodHelper
    TEMPLATE = "visit[%s]"
    REGEXP = /^visit\[.*\]$/

    def self.gen_name(klass)
      return TEMPLATE % klass
    end

    def self.match(visit_method_name)
      return REGEXP.match visit_method_name
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
      "no method in #{@visitor} to visit as #{@visited_as}"
    end
  end
end
