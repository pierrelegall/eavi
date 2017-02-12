module Eavi
  # Error raised when a Visitor do not have a visit method to handle an object.
  class NoVisitMethodError < TypeError
    attr_reader :visitor, :visited, :visited_as

    def initialize(visitor, visited, visited_as)
      @visitor = visitor
      @visited = visited
      @visited_as = visited_as
    end

    def to_s
      "no visit method in #{@visitor} for #{@visited_as} instances"
    end
  end
end
