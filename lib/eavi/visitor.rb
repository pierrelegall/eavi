require_relative "visit_method_helper"
require_relative "no_visit_method_error"

module Eavi
  # Extend a module/class or include a class with Visitor
  # to make it a dynamic visitor (see the OOP visitor pattern).
  module Visitor
    # Call the visit method associated with the type of +object+.
    #
    # @param [Object] object The object to visit
    # @param [Object] *args The arguments passed to the called visit method
    # @param [Class] as: The class which the visit method is attached
    # @returns The result of the called visit method
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
        visitor.extend(DSL)
        visitor.extend(MethodsWhenIncludedAndExtended)
        visitor.extend(MethodsWhenIncluded)
      end

      def extended(visitor)
        visitor.extend(DSL)
        visitor.extend(MethodsWhenIncludedAndExtended)
        visitor.extend(MethodsWhenExtended)
      end
    end

    # DSL methods
    module DSL
      # DSL method to add visit methods on types +types+.
      #
      # @param [Array<Class>] *types Types attached to the new visit method
      # @param [Proc] block The content of the visit method
      def def_visit(*types, &block)
        add_visit_method(*types, &block)
      end

      # DSL method to remove visit methods on types +types+.
      #
      # @param [Array<Class>] *types Types attached to the removed visit method
      def undef_visit(*types)
        remove_visit_method(*types)
      end
    end

    # Extends if included or extended
    module MethodsWhenIncludedAndExtended
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
          specialized_add_visit_method(type, block)
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

      # Returns a list of the visit method.
      def visit_methods
        specialized_visit_methods
      end

      # Returns a list of the types with a visit method.
      def visitable_types
        return visit_methods.collect do |visit_method|
          VisitMethodHelper.get_type(visit_method)
        end
      end
    end

    # Extends only when included
    module MethodsWhenIncluded
      private

      def specialized_alias_visit_method(visit_method_alias)
        define_method(visit_method_alias, instance_method(:visit))
        define_singleton_method(("def_#{visit_method_alias}").to_sym, method(:def_visit))
        define_singleton_method(("undef_#{visit_method_alias}").to_sym, method(:undef_visit))
      end

      def specialized_add_visit_method(type, block)
        define_method(VisitMethodHelper.gen_name(type), block)
      end

      def specialized_remove_visit_method(type)
        remove_method(VisitMethodHelper.gen_name(type))
      end

      def specialized_remove_method(visit_method)
        remove_method(visit_method)
      end

      def specialized_visit_methods
        return instance_methods.select do |method|
          VisitMethodHelper.match(method)
        end
      end
    end

    # Extends only when extended
    module MethodsWhenExtended
      private

      def specialized_alias_visit_method(visit_method_alias)
        define_singleton_method(visit_method_alias, method(:visit))
        define_singleton_method(("def_#{visit_method_alias}").to_sym, method(:def_visit))
        define_singleton_method(("undef_#{visit_method_alias}").to_sym, method(:undef_visit))
      end

      def specialized_add_visit_method(type, block)
        define_singleton_method(VisitMethodHelper.gen_name(type), block)
      end

      def specialized_remove_visit_method(type)
        singleton_class.send(:remove_method, VisitMethodHelper.gen_name(type))
      end

      def specialized_remove_method(visit_method)
        singleton_class.send(:remove_method, visit_method)
      end

      def specialized_visit_methods
        return methods.select do |method|
          VisitMethodHelper.match(method)
        end
      end
    end
  end
end
