require_relative '../lib/eavi/visitor'

module Eavi
  module Fixtures
    class Page
    end

    class Reader
      include Eavi::Visitor

      when_visiting Page do
        'Reading'
      end
    end

    class Printer
      extend Eavi::Visitor

      when_visiting Page do |page|
        "Printing #{page}"
      end

      when_visiting String do |string, capitalize|
        string = string.capitalize if capitalize
        return string
      end
    end

    class NewReader < Reader
    end

    class NewPrinter < Printer
    end
  end
end
