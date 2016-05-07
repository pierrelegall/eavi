module Risitor
  # Error raised when a Visitor failed to visit an object.
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
