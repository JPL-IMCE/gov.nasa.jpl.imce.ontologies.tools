require 'rgl/adjacency'
require 'rgl/transitivity'
require 'rgl/topsort'
require 'delegate'

module ClassExpression
  module Operators
    def complement
      Complement.new(self.dup)
    end
    def union(s)
      Union.new([self.dup, s])
    end
    def intersection(s)
      Intersection.new([self.dup, s])
    end
    def difference(s)
      Difference.new(self.dup, s)
    end
  end
  class Singleton
    include Operators
    def initialize(name)
      @name = name
    end
    def to_s
      @name
    end
    def ==(o)
      @name == o.name
    end
    alias :eql? :==
    def hash
      @name.hash
    end
    protected
    attr_reader :name
  end
  class Unary
    include Operators
    def initialize(s)
      @s = s
    end
    def ==(o)
      @s == o.s
    end
    alias :eql? :==
    def hash
      @s.hash
    end
    protected
    attr_reader :s
  end
  class Complement < Unary
    def to_s
      'complement(' + @s.to_s + ')'
    end
    def complement
      @s.dup
    end
  end
  class Binary
    def initialize(a, b)
      @a = a
      @b = b
    end
    def to_s
      '(' + @a.to_s + ',' + @b.to_s + ')'
    end
    def ==(o)
      [@a, @b] == [o.a, o.b]
    end
    alias :eql? :==
    def hash
      [@a, @b].hash
    end
    protected
    attr_reader :a, :b
  end
  class Difference < Binary
    def to_s
      'difference' + super
    end
  end
  class NAry
    def initialize(s)
      @s = s.to_set
    end
    def to_s
      '(' + @s.to_a.join(',') + ')'
    end
    def ==(o)
      @s == o.s
    end
    alias :eql? :==
    def hash
      @s.hash
    end
    protected
    attr_reader :s
  end
  class Union < NAry
    def to_s
      'union' + super
    end
    def union(o)
      Union.new(@s.dup << o)
    end
  end
  class Intersection < NAry
    def to_s
      'intersection' + super
    end
    def intersection(o)
      Intersection.new(@s.dup << o)
    end
  end

end

# Each vertex of a Taxonomy is a set of class IRIs representing a union.

class Union < Set

  def to_s
    '{' + to_a.join(',') + '}'
  end
  
end

# A Taxonomy is a directed graph of class unions.

class Taxonomy < DelegateClass(RGL::DirectedAdjacencyGraph)

  def initialize(g = RGL::DirectedAdjacencyGraph.new)
    super(g)
  end

  def self.[](*a)
    Taxonomy.new((RGL::DirectedAdjacencyGraph[*a]))
  end
  
  # Find a vertex with multiple parents. Returns nil if none.
  
  def multi_parent_child
    each_vertex.detect { |v| direct_parents_of(v).length > 1 }
  end

  # Find children of a vertex.
  
  def children_of(v)
    edges.select { |e| e.source == v }.map { |e| e.target }
  end

  # Find descendants of a vertex.
  
  def descendants_of(v, key = Random.rand(1000))
    if (c = children_of(v)).empty?
      []
    else
      c + c.flat_map { |x| descendants_of(x, key) }
    end
  end

  # Find direct children of a vertex.
  
  def direct_children_of(v)
    c = children_of(c)
    c - c.flat_map { |x| descendants_of(x) }
  end
  
  # Find parents of a vertex.
  
  def parents_of(v)
    edges.select { |e| e.target == v }.map { |e| e.source }
  end

  # Find ancestors of a vertex.
  
  def ancestors_of(v, key = Random.rand(1000))
    if (p = parents_of(v)).empty?
      []
    else
      p + p.flat_map { |x| ancestors_of(x, key) }
    end
  end

  # Find direct parents of a vertex.
  
  def direct_parents_of(v)
    p = parents_of(v)
    p - p.flat_map { |x| ancestors_of(x) }
  end
  
  # Form transitive reduction

  alias :inner_transitive_reduction :transitive_reduction
  def transitive_reduction
    Taxonomy.new(inner_transitive_reduction)
  end
  
  # Create a new Taxonomy with the specified child c and parent set
  # ps = {p1, p2,... pn} vertices replaced by {p1-c, p2-c,... pn-c, c}.
  
  def partition_vertices(c, ps, count = 0, &block)

    unless old_vertex = ps.first
      yield(:partitioning, self, child, parents, count) if block_given?

      new_vertex = old_vertex.difference(c)

      g = RGL::DirectedAdjacencyGraph.new

      parent_list = Set.new
      global_parent_list = Set.new
      child_list = Set.new

      edges.each do |edge|
        source_in_s = edge.source == old_vertex
        target_in_s = edge.target == old_vertex
        if source_in_s && target_in_s
          # do nothing
        elsif source_in_s
          child_list << edge.target
        elsif target_in_s
          parent_list << edge.source
        else
          g.add_edge(edge.source, edge.target)
        end
      end

      direct_children = child_list - child_list.flat_map { |x| descendants_of(x) }
      direct_children.each do |c|
        g.add_edge(new_vertex, c)
      end

      direct_parents = parent_list - parent_list.flat_map { |x| ancestors_of(x) }
      direct_parents.each do |p|
        g.add_edge(p, new_vertex)
      end

      Taxonomy.new(g).partition_vertices(ps.drop(1))
    else
      yield(:partitioned, nil, nil, nil, count) if block_given?
      self
    end
      
  end

  # Recursively merge vertices until the resulting Taxonomy is a tree.
  
  def treeify(count = 0, &block)
    if child = multi_parent_child
      parents = direct_parents_of(child)
      yield(:merging, self, child, parents, count) if block_given?
      count += parents.length
      partition_parents(child, parents).raise_child(child).treeify(count, &block)
    else
      yield(:merged, nil, nil, nil, count) if block_given?
      self
    end
  end

  # Excise specific vertex.

  def excise_vertex(v)
    g = RGL::DirectedAdjacencyGraph.new
    parents = Set.new
    children = Set.new
    edges.each do |edge|
      if edge.source == v
        children << edge.target
      elsif edge.target == v
        parents << edge.source
      else
        g.add_edge(edge.source, edge.target)
      end
    end
    parents.each do |p|
      children.each do |c|
        g.add_edge(p, c)
      end
    end
    
    Taxonomy.new(g)
  end

  # Excise a set of vertices.

  def excise_vertices(s, count = 0, &block)
    unless s.empty?
      count += 1
      first, rest = s.first, s.drop(1)
      yield :excising, first, count if block_given?
      excise_vertex(first).excise_vertices(rest, count, &block)
    else
      yield :excised, nil, count if block_given?
      self
    end
  end
  
  # Excise all vertices that include a match to a given pattern.

  def excise_pattern(pattern, count = 0, &block)
    if m = vertices.detect { |v| v.any? { |x| x =~ pattern } }
      count += 1
      yield :excising, m, count if block_given?
      excise_vertex(m).excise_pattern(pattern, count, &block)
    else
      yield :excised, nil, count if block_given?
      self
    end
  end
  
  # Create a new Taxonomy rooted at the specified element.
  
  def root_at(root)
    g = RGL::DirectedAdjacencyGraph.new
    edges.each do |edge|
      g.add_edge(edge.source, edge.target)
    end
    top_vertices = g.edges.inject(Set.new(g.vertices)) do |set, edge|
      set.delete(edge.target)
    end
    top_vertices.each do |v|
      g.add_edge(root, v)
    end
    Taxonomy.new(g)
  end

  # Return an array of arrays representing groups of siblings.
  
  def sibling_groups
    vertices.map do |v|
      edges.select { |e| e.source == v }.map { |e| e.target }
    end.select do |g|
      g.length > 1
    end

  end

end

require 'minitest/autorun'

class TestSingleton < Minitest::Test

  def setup
    @a1 = ClassExpression::Singleton.new('a')
    @a2 = ClassExpression::Singleton.new('a')
    @b = ClassExpression::Singleton.new('b')
  end

  def test_singleton_equality
    assert_equal @a1, @a2
    refute_equal @a1, @b
  end

  def test_singleton_to_s
    assert_equal 'a', @a1.to_s
    assert_equal 'b', @b.to_s
  end
  
end

class TestComplement < Minitest::Test

  def setup
    @a1 = ClassExpression::Singleton.new('a')
    @a2 = ClassExpression::Singleton.new('a')
    @b = ClassExpression::Singleton.new('b')
    @a1c = ClassExpression::Complement.new(@a1)
    @a2c = ClassExpression::Complement.new(@a2)
    @bc = ClassExpression::Complement.new(@b)
    
  end

  def test_complement_equality
    assert_equal @a1c, @a2c
    assert_equal @a1.complement, @a1c
    refute_equal @a1c, @bc
    refute_equal @a1.complement, @bc
  end

  def test_complement_idempotency
    assert_equal @b, @bc.complement
    assert_equal @b, @b.complement.complement
  end

  def test_complement_to_s
    assert_equal 'complement(a)', @a1c.to_s
    assert_equal 'complement(b)', @bc.to_s
  end
  
end

class TestDifference < Minitest::Test

  def setup
    @a = ClassExpression::Singleton.new('a')
    @b = ClassExpression::Singleton.new('b')
    @dab1 = ClassExpression::Difference.new(@a, @b)
    @dab2 = ClassExpression::Difference.new(@a, @b)
    @dba = ClassExpression::Difference.new(@b, @a)
  end

  def test_difference_equality
    assert_equal @dab1, @dab2
    refute_equal @dab1, @dba
    refute_equal @dab2, @dba
  end

  def test_difference_to_s
    assert_equal 'difference(a,b)', @dab1.to_s
  end
  
end

class TestUnion < Minitest::Test

  def setup
    @a = ClassExpression::Singleton.new('a')
    @b = ClassExpression::Singleton.new('b')
    @c = ClassExpression::Singleton.new('c')
    @aub1 = ClassExpression::Union.new([@a, @b])
    @aub2 = ClassExpression::Union.new([@a, @b])
    @bua = ClassExpression::Union.new([@b, @a])
    @auc = ClassExpression::Union.new([@a, @c])
    @aubuc = ClassExpression::Union.new([@a, @b, @c])
  end

  def test_union_equality
    assert_equal @aub1, @aub2
    assert_equal @aub1, @bua
    refute_equal @aub1, @auc
  end

  def test_union_union
    assert_equal @aub1.union(@c), @aubuc
    assert_equal @bua.union(@c), @aubuc
    assert_equal @a.union(@b).union(@c), @aubuc
  end
  
  def test_union_to_s
    assert_equal 'union(a,b)', @aub2.to_s
  end
  
end

class TestIntersection < Minitest::Test

  def setup
    @a = ClassExpression::Singleton.new('a')
    @b = ClassExpression::Singleton.new('b')
    @c = ClassExpression::Singleton.new('c')
    @aib1 = ClassExpression::Intersection.new([@a, @b])
    @aib2 = ClassExpression::Intersection.new([@a, @b])
    @bia = ClassExpression::Intersection.new([@b, @a])
    @aic = ClassExpression::Intersection.new([@a, @c])
    @aibic = ClassExpression::Intersection.new([@a, @b, @c])
  end

  def test_intersection_equality
    assert_equal @aib1, @aib2
    assert_equal @aib1, @bia
    refute_equal @aib1, @aic
  end

  def test_intersection_intersection
    assert_equal @aib1.intersection(@c), @aibic
    assert_equal @bia.intersection(@c), @aibic
    assert_equal @a.intersection(@b).intersection(@c), @aibic
  end
  
  def test_intersection_to_s
    assert_equal 'intersection(a,b)', @aib1.to_s
  end
  
end

class TestEmptyTaxonomy < Minitest::Test

  def setup
    @t = Taxonomy.new
  end

  def test_treeify
    tree = @t.treeify
    assert_kind_of(Taxonomy, tree)
  end
  
end

class TestSingletonTaxonomy < Minitest::Test

  def setup
    @t = Taxonomy.new
    @a = ClassExpression::Singleton.new('a')
    @t.add_vertex(@a)
  end

  def test_treeify
    assert_nil @t.multi_parent_child
    tree = @t.treeify
    assert tree.vertices == [ @a ]
    assert_empty tree.edges
  end
  
end

class Test3Tree < Minitest::Test

  def setup
    @t = Taxonomy[1,2, 1,3]
   end

  def test_treeify
    assert_nil @t.multi_parent_child
    tree = @t.treeify
    assert_equal tree.vertices, @t.vertices
    assert_equal tree.edges, @t.edges
  end
  
end

class Test3InvertedTree < Minitest::Test

  def setup
    @t = Taxonomy[1,3, 2,3]
   end

  def test_treeify
    assert_equal 3, @t.multi_parent_child
    # tree = @t.treeify
  end
  
end

