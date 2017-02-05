require_relative 'visit_method_helper'
require_relative 'no_visit_method_error'

module Eavi
  # The Visitor module can extend a module or include a class
  # to make it a dynamic visitor (see the OOP visitor pattern).
  module Visitor
    # Calling visit execute the method associated with the
    # type of +object+.
    def visit(object, *args, as: object.class)
      as.ancestors.each do |type|
        visit_method_name = VisitMethodHelper.gen_name(type)
        next unless respond_to?(visit_method_name)
        return send(visit_method_name, object, *args)
      end
      raise NoVisitMethodError.new(self, object, as)
    end

    class << self
      def included(visitor)
        visitor.extend(ClassDSL)
        visitor.extend(ClassMethods)
        visitor.extend(ClassMethodsWhenIncluded)
      end

      def extended(visitor)
        visitor.extend(ClassDSL)
        visitor.extend(ClassMethods)
        visitor.extend(ClassMethodsWhenExtended)
      end
    end

    # Class DSL methods
    module ClassDSL
      def def_visit(*types, &block)
        add_visit_method(*types, &block)
      end

      def undef_visit(*types)
        remove_visit_method(*types)
      end
    end

    # List of the methods extended by a Visitor.
    module ClassMethods
      # Alias the `visit` method.
      def alias_visit_method(visit_method_alias)
        specialized_alias_visit_method(visit_method_alias)
      end

      # Add/override a visit method for the types +types+.
      def add_visit_method(*types, &block)
        block = block.curry(1) if block.arity.zero?
        types.each do |type|
          specialized_add_visit_method(type, &block)
        end
      end

      # Remove the visit methods for the types +types+.
      def remove_visit_method(*types)
        types.each do |type|
          specialized_remove_visit_method(type)
        end
      end

      # Remove all the visit methods.
      def reset_visit_methods
        visit_methods.each do |visit_method|
          specialized_remove_method(visit_method)
        end
      end

      # Return a list of the visit method.
      def visit_methods
        return methods.select do |method|
          VisitMethodHelper.match(method)
        end
      end

      # Return a list of the types with a visit method.
      def visitable_types
        return visit_methods.collect do |visit_method|
          VisitMethodHelper.get_type(visit_method)
        end
      end
    end

    # List of the methods extended by a Visitor when included.
    module ClassMethodsWhenIncluded
      private

      def specialized_alias_visit_method(visit_method_alias)
        define_method(visit_method_alias, instance_method(:visit))
      end

      def specialized_add_visit_method(klass, &block)
        define_method(VisitMethodHelper.gen_name(klass), block)
      end

      def specialized_remove_visit_method(klass)
        remove_method(VisitMethodHelper.gen_name(klass))
      end

      def specialized_remove_method(visit_method)
        remove_method(visit_method)
      end
    end

    # List of the methods extended by a Visitor when included.
    module ClassMethodsWhenExtended
      private

      def specialized_alias_visit_method(visit_method_alias)
        define_singleton_method(visit_method_alias, method(:visit))
      end

      def specialized_add_visit_method(klass, &block)
        define_singleton_method(VisitMethodHelper.gen_name(klass), block)
      end

      def specialized_remove_visit_method(klass)
        singleton_class.send(:remove_method, VisitMethodHelper.gen_name(klass))
      end

      def specialized_remove_method(visit_method)
        singleton_class.send(:remove_method, visit_method)
      end
    end
  end
end
