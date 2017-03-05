require_relative 'visit_method_helper'
require_relative 'no_visit_method_error'

module Eavi
  # Extend a module/class or include a class with Visitor
  # to make it a dynamic visitor (see the OOP visitor pattern).
  module Visitor
    # Call the visit method associated with the type of +object+.
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
        visitor.extend(ModuleDSL)
        visitor.extend(ModuleMethods)
        visitor.extend(ModuleMethodsWhenIncluded)
      end

      def extended(visitor)
        visitor.extend(ModuleDSL)
        visitor.extend(ModuleMethods)
        visitor.extend(ModuleMethodsWhenExtended)
      end
    end

    # Domain-Specific Language for the module/class
    module ModuleDSL
      # DSL method to add visit methods on types +types+.
      def def_visit(*types, &block)
        add_visit_method(*types, &block)
      end

      # DSL method to remove visit methods on types +types+.
      def undef_visit(*types)
        remove_visit_method(*types)
      end
    end

    # Extends if included or extended
    module ModuleMethods
      # Alias the `visit` method.
      def alias_visit_method(visit_method_alias)
        specialized_alias_visit_method(visit_method_alias)
      end

      # Add/override a visit method for the types +types+.
      def add_visit_method(*types, &block)
        if block.arity.zero?
          original_block = block
          block = proc { |_| instance_exec(&original_block) }
        end
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

    # Extends only when included
    module ModuleMethodsWhenIncluded
      private

      def specialized_alias_visit_method(visit_method_alias)
        define_method(visit_method_alias, instance_method(:visit))
      end

      def specialized_add_visit_method(type, &block)
        define_method(VisitMethodHelper.gen_name(type), block)
      end

      def specialized_remove_visit_method(type)
        remove_method(VisitMethodHelper.gen_name(type))
      end

      def specialized_remove_method(visit_method)
        remove_method(visit_method)
      end
    end

    # Extends only when extended
    module ModuleMethodsWhenExtended
      private

      def specialized_alias_visit_method(visit_method_alias)
        define_singleton_method(visit_method_alias, method(:visit))
      end

      def specialized_add_visit_method(type, &block)
        define_singleton_method(VisitMethodHelper.gen_name(type), block)
      end

      def specialized_remove_visit_method(type)
        singleton_class.send(:remove_method, VisitMethodHelper.gen_name(type))
      end

      def specialized_remove_method(visit_method)
        singleton_class.send(:remove_method, visit_method)
      end
    end
  end
end
