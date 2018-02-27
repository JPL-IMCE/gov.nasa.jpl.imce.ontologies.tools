require 'test/unit'
require 'union'
require 'klass'

class TestKlass < Test::Unit::TestCase
  
  def test_to_s_1
    a = Klass.new('A')
    u = Union.new([a])
    assert_equal 'Union(Class(A))', u.to_s
  end

  def test_to_s_2
    a = Klass.new('A')
    b = Klass.new('B')
    u = Union.new([a, b])
    assert_equal 'Union(Class(A),Class(B))', u.to_s
  end
  
  def test_eql
    a1 = Klass.new('A')
    a2 = Klass.new('A')
    u1 = Union.new([a1])
    u2 = Union.new([a2])
    assert_equal u1, u1
    assert_equal u1, u2
  end

  def test_append
    a1 = Klass.new('A')
    a2 = Klass.new('A')
    a3 = Klass.new('A')
    u1 = Union.new([a1])
    u2 = Union.new([a2])
    u2 << a3
    assert_equal u1, u2
  end

  def test_merge
    a = Klass.new('A')
    b = Klass.new('B')
    c = Klass.new('C')
    d = Klass.new('D')
    u1 = Union.new([a, b])
    u2 = Union.new([c, d])
    u3 = u1.merge(u2)
    u4 = Union.new([a, b, c, d])
    assert_equal u3, u4
  end
  
end
