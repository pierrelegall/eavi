module Risitor
  module VisitMethodHelper
    TEMPLATE = "visit[%s]"
    REGEXP = /^visit\[(.*)\]$/

    def self.gen_name(klass)
      return TEMPLATE % klass.name
    end

    def self.match(visit_method_name)
      return REGEXP.match visit_method_name
    end

    def self.get_type(visit_method)
      type_symbol = match(visit_method).captures[0]
      return const_get type_symbol
    end
  end

  private_constant :VisitMethodHelper
end
