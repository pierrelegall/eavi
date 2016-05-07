module Risitor
  # Helper for visit methods generation, matching & co.
  module VisitMethodHelper
    TEMPLATE = "visit[%s]"
    REGEXP = /^visit\[(.*)\]$/

    # Return a visit method name for the type +type+.
    def self.gen_name(type)
      return TEMPLATE % type.name
    end

    # Return true if the +visit_method_name+ is a well formed
    # visit method name, else false.
    def self.match(visit_method_name)
      return REGEXP.match visit_method_name
    end

    # Return the type matching a visit method.
    def self.get_type(visit_method)
      type_symbol = match(visit_method).captures[0]
      return const_get type_symbol
    end
  end
end
