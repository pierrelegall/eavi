require_relative '../lib/eavi/visitor'

# A type of visitors
class Reader
  include Eavi::Visitor
end

# A subtype of a class of visitors
class NiceReader < Reader
end

# A singleton visitor
class Printer
  extend Eavi::Visitor
end

# A subtype of a singleton visitor
class NicePrinter < Printer
end

# A type of visited object
class Page
end

# A subtype of visited object
class NicePage < Page
end
