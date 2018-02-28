require 'node'
require 'test/unit'

class TestNode < Test::Unit::TestCase

  def test_to_s
    classes = %w{A B C}
    u = Union.new(classes.map { |c| Klass.new(c) })
    n = Node.new(u)
    s = "Node(Union(#{classes.map { |c| %Q{Class(#{c})}}.join(',')}))"
    assert_equal s, n.to_s
  end

  def test_children
    na = Node.new(Union.new())
    nb = Node.new(Union.new())

    assert_empty na.children
    assert_empty nb.children
    
    na.add_child(nb)
    assert_equal Set.new([nb]), na.children

    na.delete_child(nb)
    assert_empty nb.children
  end
  
  def test_parents
    na = Node.new(Union.new())
    nb = Node.new(Union.new())

    assert_empty na.parents
    assert_empty nb.parents
    
    na.add_parent(nb)
    assert_equal Set.new([nb]), na.parents

    na.delete_parent(nb)
    assert_empty nb.parents
  end
  
end
