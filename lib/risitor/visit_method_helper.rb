module Risitor
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
end
