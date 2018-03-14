require 'node'

gem 'minitest'
require 'minitest/autorun'

class TestNode < Minitest::Test

  def setup
    @node = 'A'.upto('O').map { |l| Node.new(Union.new([Klass.new(l)])) }
    0.upto(6) do |p|
      c = @node[2 * p + 1..2 * p + 2]
      @node[p].add_children(c)
    end
  end
  
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
    nc = Node.new(Union.new())
    nd = Node.new(Union.new())

    assert_empty na.children
    
    na.add_child(nb)
    assert_equal Set.new([nb]), na.children

    na.delete_child(nb)
    assert_empty nb.children

    na.add_children([nb, nc, nd])
    assert_equal Set.new([nb, nc, nd]), na.children

    na.delete_children([nb, nc])
    assert_equal Set.new([nd]), na.children

    na.clear_children
    assert_empty na.children
  end
  
  def test_parents
    na = Node.new(Union.new())
    nb = Node.new(Union.new())
    nc = Node.new(Union.new())
    nd = Node.new(Union.new())

    assert_empty na.parents
    
    na.add_parent(nb)
    assert_equal Set.new([nb]), na.parents

    na.delete_parent(nb)
    assert_empty nb.parents

    na.add_parents([nb, nc, nd])
    assert_equal Set.new([nb, nc, nd]), na.parents

    na.delete_parents([nb, nc])
    assert_equal Set.new([nd]), na.parents

    na.clear_parents
    assert_empty na.parents
  end

  def test_traverse 
    r1 = []
    @node[0].traverse do |n|
      r1 << n
    end
    a1 = %w{ A B D H I E J K C F L M G N O }.map do |l|
      Node.new(Union.new([Klass.new(l)]))
    end
    assert_equal a1, r1
    a2 = Set.new(@node.drop(1))
    r2 = @node[0].descendants
    assert_equal a2, r2
    assert_equal Set.new, @node[14].descendants
  end
  
end
