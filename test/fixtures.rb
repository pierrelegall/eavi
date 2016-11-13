require_relative '../lib/risitor/visitor'

module Risitor
  module Fixtures
    class Page
    end

    class Reader
      include Risitor::Base

      when_visiting Page do
        'Reading'
      end
    end

    class Printer
      extend Risitor::Base

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
