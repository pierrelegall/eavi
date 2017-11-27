require 'minitest/autorun'

require_relative '../lib/eavi/no_visit_method_error'

describe Eavi::NoVisitMethodError do
  it 'is catched as TypeError' do
    assert_raises TypeError do
      raise Eavi::NoVisitMethodError.new(nil, nil, nil)
    end
  end
end
