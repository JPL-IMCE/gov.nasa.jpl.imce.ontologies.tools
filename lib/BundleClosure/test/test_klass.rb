require 'test/unit'
require 'klass'

class TestKlass < Test::Unit::TestCase
  
  def test_to_s
    a = Klass.new('A')
    assert_equal 'Class(A)', a.to_s
  end

  def test_eql
    a1 = Klass.new('A')
    a2 = Klass.new('A')
    assert_equal a1, a2
  end
  
end
