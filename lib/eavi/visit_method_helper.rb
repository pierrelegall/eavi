module Eavi
  # Helper for visit methods generation, matching & co.
  module VisitMethodHelper
    TEMPLATE = 'visit[%s]'.freeze
    REGEXP = /^visit\[(.*)\]$/

    # Returns a visit method name for the type +type+.
    def self.gen_name(type)
      return TEMPLATE % type.name
    end

    # Returns true if the +visit_method_name+ is a well formed
    # visit method name, else false.
    def self.match(visit_method_name)
      return REGEXP.match(visit_method_name)
    end

    # Returns the type matching a visit method.
    def self.get_type(visit_method)
      type_symbol = match(visit_method).captures[0]
      return const_get(type_symbol)
    end
  end
end
