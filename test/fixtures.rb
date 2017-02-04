require_relative '../lib/eavi/visitor'

module Eavi
  module Fixtures
    class Page
    end

    class Reader
      include Eavi::Visitor

      visit_for Page do
        'Reading'
      end
    end

    class Printer
      extend Eavi::Visitor

      visit_for Page do |page|
        "Printing #{page}"
      end

      visit_for String do |string, capitalize|
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
