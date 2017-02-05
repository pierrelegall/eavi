require_relative '../lib/eavi/visitor'

module Eavi
  module Fixtures
    class Page
    end

    class Reader
      include Eavi::Visitor

      def_visit Page do
        'Reading'
      end
    end

    class Printer
      extend Eavi::Visitor

      def_visit Page do |page|
        "Printing #{page}"
      end

      def_visit String do |string, capitalize|
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
