require 'minitest/autorun'

require_relative '../lib/eavi/visitor'
require_relative 'fixtures'

describe Eavi::Visitor do
  describe 'when included' do
    before :each do
      Reader.reset_visit_methods
      @reader = Reader.new
      @nice_reader = NiceReader.new
      @page = Page.new
      @nice_page = NicePage.new
    end

    it 'respects the interface' do
      assert_respond_to @reader, :visit
      refute_respond_to Reader, :visit

      assert_respond_to Reader, :alias_visit_method
      assert_respond_to Reader, :add_visit_method
      assert_respond_to Reader, :remove_visit_method
      assert_respond_to Reader, :reset_visit_methods
      assert_respond_to Reader, :visit_methods
      assert_respond_to Reader, :visitable_types

      assert_respond_to Reader, :def_visit
      assert_respond_to Reader, :undef_visit
    end

    describe '#visit' do
      it 'call the visit method for the appropriate type' do
        Reader.class_eval do
          def_visit Page do
            'Reading'
          end
        end

        assert_equal @reader.visit(@page), 'Reading'
        assert_equal @reader.visit(@nice_page), 'Reading'
        assert_equal @nice_reader.visit(@page), 'Reading'
        assert_equal @nice_reader.visit(@nice_page), 'Reading'
      end

      it 'visit as something else if asked for' do
        Reader.class_eval do
          def_visit Page do
            'As page'
          end

          def_visit String do
            'As string'
          end
        end

        assert_equal @reader.visit(@page, as: String), 'As string'
      end

      it 'raises error when trying to visit without visit method' do
        assert_raises Eavi::NoVisitMethodError do
          @reader.visit('string')
        end
        assert_raises Eavi::NoVisitMethodError do
          @reader.visit('string', as: String)
        end
        assert_raises Eavi::NoVisitMethodError do
          @reader.visit(@page, as: String)
        end

        assert_raises TypeError do
          raise Eavi::NoVisitMethodError.new(nil, nil, nil)
        end
      end

      it 'has self as the visitor instance in blocks (with first arg)' do
        Reader.class_eval do
          def_visit Page do |_|
            self
          end
        end

        assert_same @reader.visit(@page), @reader
      end

      it 'has self as the visitor instance in blocks (without first arg)' do
        Reader.class_eval do
          def_visit Page do
            self
          end
        end

        assert_same @reader.visit(@page), @reader
      end

      it 'can return arguments, not a copy' do
        Reader.class_eval do
          def_visit Page do |page|
            page
          end
        end

        assert_same @reader.visit(@page), @page
      end

      it 'uses the following arguments of given blocks' do
        Reader.class_eval do
          def_visit String do |_, a, b|
            { a: a, b: b }
          end
        end

        assert_equal @reader.visit('something', 1, 2), { a: 1, b: 2 }

        Reader.class_eval do
          def_visit String do |_, *args|
            args
          end
        end

        assert_equal @reader.visit('something', 1, 2), [1, 2]
      end
    end

    describe '.alias_visit_method' do
      it do
        Reader.class_eval do
          alias_visit_method :read

          def_visit Page do
            # [...]
          end
        end

        assert_respond_to @reader, :read
      end
    end

    describe '.add_visit_method' do
      it do
        Reader.class_eval do
          def_visit Array do
            'Visiting an array'
          end
        end

        assert_equal @reader.visit([]), 'Visiting an array'
      end
    end

    describe '.remove_visit_method' do
      it do
        Reader.class_eval do
          def_visit Page do
            'Printing'
          end
        end
        Reader.remove_visit_method(Page)

        assert_raises Eavi::NoVisitMethodError do
          @reader.visit(@page)
        end
      end
    end

    describe '.visit_methods' do
      it do
        Reader.class_eval do
          def_visit String, Array, Hash do
            # [...]
          end
        end

        assert_equal Reader.visit_methods.size, 3
        Reader.visit_methods.each do |method|
          assert_respond_to @reader, method
        end
      end
    end

    describe '.reset_visit_methods' do
      it do
        Reader.class_eval do
          def_visit Page do
            'Printing'
          end
        end

        refute_empty Reader.visit_methods

        Reader.reset_visit_methods

        assert_empty Reader.visit_methods
      end
    end

    describe '.visitable_types' do
      it do
        Reader.class_eval do
          def_visit String, Array, Hash do
            # [...]
          end
        end

        assert_includes Reader.visitable_types, String
        assert_includes Reader.visitable_types, Array
        assert_includes Reader.visitable_types, Hash
      end
    end
  end

  describe 'when extended' do
    before :each do
      Printer.reset_visit_methods
      @page = Page.new
      @nice_page = NicePage.new
    end

    it 'respects the interface' do
      assert_respond_to Printer, :visit

      assert_respond_to Printer, :alias_visit_method
      assert_respond_to Printer, :add_visit_method
      assert_respond_to Printer, :remove_visit_method
      assert_respond_to Printer, :reset_visit_methods
      assert_respond_to Printer, :visit_methods
      assert_respond_to Printer, :visitable_types

      assert_respond_to Printer, :def_visit
      assert_respond_to Printer, :undef_visit
    end

    describe '.visit' do
      it 'call the visit method for the appropriate type' do
        Printer.class_eval do
          def_visit Page do
            'Printing'
          end
        end

        assert_equal Printer.visit(@page), 'Printing'
        assert_equal Printer.visit(@nice_page), 'Printing'
        assert_equal NicePrinter.visit(@page), 'Printing'
        assert_equal NicePrinter.visit(@nice_page), 'Printing'
      end

      it 'visit as something else if asked for' do
        Printer.class_eval do
          def_visit Page do
            'As page'
          end

          def_visit String do
            'As string'
          end
        end

        assert_equal Printer.visit(@page, as: String), 'As string'
      end

      it 'raises error when trying to visit without visit method' do
        assert_raises Eavi::NoVisitMethodError do
          Printer.visit('string')
        end
        assert_raises Eavi::NoVisitMethodError do
          Printer.visit('string', as: String)
        end
        assert_raises Eavi::NoVisitMethodError do
          Printer.visit(@page, as: String)
        end

        assert_raises TypeError do
          raise Eavi::NoVisitMethodError.new(nil, nil, nil)
        end
      end

      it 'has self as the singleton visitor in blocks (with first arg)' do
        Printer.class_eval do
          def_visit Page do |_|
            self
          end
        end

        assert_same Printer.visit(@page), Printer
      end

      it 'has self as the singleton visitor in blocks (without first arg)' do
        Printer.class_eval do
          def_visit Page do
            self
          end
        end

        assert_same Printer.visit(@page), Printer
      end

      it 'can return arguments, not a copy' do
        Printer.class_eval do
          def_visit Page do |page|
            page
          end
        end

        assert_same Printer.visit(@page), @page
      end

      it 'uses the following arguments of given blocks' do
        Printer.class_eval do
          def_visit String do |_, a, b|
            { a: a, b: b }
          end
        end

        assert_equal Printer.visit('something', 1, 2), { a: 1, b: 2 }

        Printer.class_eval do
          def_visit String do |_, *args|
            args
          end
        end

        assert_equal Printer.visit('something', 1, 2), [1, 2]
      end
    end

    describe '.alias_visit_method' do
      it do
        Printer.class_eval do
          alias_visit_method :print

          def_visit Page do
            # [...]
          end
        end

        assert_respond_to Printer, :print
      end
    end

    describe '.add_visit_method' do
      it do
        Printer.class_eval do
          def_visit Array do
            'Visiting an array'
          end
        end

        assert_equal Printer.visit([]), 'Visiting an array'
      end
    end

    describe '.remove_visit_method' do
      it do
        Printer.class_eval do
          def_visit Page do
            'Printing'
          end
        end
        Printer.remove_visit_method(Page)

        assert_raises Eavi::NoVisitMethodError do
          Printer.visit(@page)
        end
      end
    end

    describe '.visit_methods' do
      it do
        Printer.class_eval do
          def_visit String, Array, Hash do
            # [...]
          end
        end

        assert_equal Printer.visit_methods.size, 3
        Printer.visit_methods.each do |method|
          assert_respond_to Printer, method
        end
      end
    end

    describe '.reset_visit_methods' do
      it do
        Printer.class_eval do
          def_visit Page do
            'Printing'
          end
        end

        refute_empty Printer.visit_methods

        Printer.reset_visit_methods

        assert_empty Printer.visit_methods
      end
    end

    describe '.visitable_types' do
      it do
        Printer.class_eval do
          def_visit String, Array, Hash do
            # [...]
          end
        end

        assert_includes Printer.visitable_types, String
        assert_includes Printer.visitable_types, Array
        assert_includes Printer.visitable_types, Hash
      end
    end
  end
end
