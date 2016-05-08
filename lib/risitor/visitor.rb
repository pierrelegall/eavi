require_relative './no_visit_method_error'
require_relative './visit_method_helper'

module Risitor
  # The Visitor module can extend a module or include a class
  # to make it a dynamic visitor (see the OOP visitor pattern).
  module Visitor
    # Calling visit execute the method associated with the
    # type of +object+.
    def visit(object, *args, as: object.class)
      as.ancestors.each do |type|
        visit_method = VisitMethodHelper.gen_name(type)
        next unless respond_to? visit_method
        return send(visit_method, object, *args)
      end
      raise NoVisitMethodError.new(self, object, as)
    end

    # List of the methods extended by a Visitor
    module ClassMethods
      # Alias the `visit` method
      def alias_visit_method(visit_method_alias)
        define_new_visit_method(visit_method_alias)
      end

      # Add/overrie a visit method for the types +types+.
      def add_visit_method(*types, &block)
        block = block.curry(1) if block.arity == 0
        types.each do |type|
          define_visit_method_for type, &block
        end
      end

      # Remove the visit methods for the types +types+.
      def remove_visit_method(*types)
        types.each do |type|
          undefine_visit_method_for type
        end
      end

      # Remove all the visit methods.
      def reset_visit_methods
        visit_methods.each do |visit_method|
          undefine_visit_method visit_method
        end
      end

      # Return a list of the visit method.
      def visit_methods
        return methods.select do |method|
          VisitMethodHelper.match method
        end
      end

      # Return a list of the types with a visit method.
      def visitable_types
        return visit_methods.collect do |visit_method|
          VisitMethodHelper.get_type(visit_method)
        end
      end

      alias_method :when_visiting, :add_visit_method
    end

    # List of the methods extended by a Visitor when included.
    module ClassMethodsWhenIncluded
      private

      def define_new_visit_method(new_visit_method)
        define_method new_visit_method, instance_method(:visit)
      end

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

    # List of the methods extended by a Visitor when included.
    module ClassMethodsWhenExtended
      private

      def define_new_visit_method(new_visit_method)
        define_singleton_method new_visit_method, method(:visit)
      end

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

  Base = Visitor
end
