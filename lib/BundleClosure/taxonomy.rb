require 'rgl/adjacency'
require 'rgl/transitivity'
require 'delegate'

module ClassExpression
  module Operators
    def complement
      Complement.new(self.dup)
    end
    def difference(s)
      Difference.new(self.dup, s)
    end
    def union(s)
      Union.new([self.dup, s])
    end
    def intersection(s)
      Intersection.new([self.dup, s])
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
    alias :to_atom :to_s
    def ==(o)
      self.class == o.class && self.name == o.name
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
      self.class == o.class && self.s == o.s
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
      @s.to_atom + %q{'}
    end
    alias :to_atom :to_s
    def complement
      @s.dup
    end
  end
  class Binary
    include Operators
    def initialize(a, b)
      @a = a
      @b = b
    end
    def to_atom
      '(' + to_s + ')'
    end
    def ==(o)
      self.class == o.class && [self.a, self.b] == [o.a, o.b]
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
      @a.to_atom + '\\' + @b.to_atom
    end
  end
  class NAry
    include Operators
    def initialize(s)
      @s = s.to_set
    end
    def to_s(c)
      @s.to_a.join(c)
    end 
    def to_atom
      '(' + to_s + ')'
    end
    def ==(o)
      self.class == o.class && self.s == o.s
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
      super("\u222A")
    end
    def union(o)
      Union.new(@s.dup << o)
    end
  end
  class Intersection < NAry
    def to_s
      super("\u2229")
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
    Set.new(edges.select { |e| e.source == v }.map { |e| e.target })
  end

  # Find descendants of a vertex.
  
  def descendants_of(v, key = Random.rand(1000))
    if (c = children_of(v)).empty?
      Set.new
    else
      Set.new(c + c.flat_map { |x| descendants_of(x, key).to_a })
    end
  end

  # Find direct children of a vertex.
  
  def direct_children_of(v)
    c = children_of(v)
    Set.new(c - c.flat_map { |x| descendants_of(x).to_a })
  end
  
  # Find parents of a vertex.
  
  def parents_of(v)
    Set.new(edges.select { |e| e.target == v }.map { |e| e.source })
  end

  # Find ancestors of a vertex.
  
  def ancestors_of(v, key = Random.rand(1000))
    if (p = parents_of(v)).empty?
      Set.new
    else
      Set.new(p + p.flat_map { |x| ancestors_of(x, key).to_a })
    end
  end

  # Find direct parents of a vertex.
  
  def direct_parents_of(v)
    p = parents_of(v)
    Set.new(p - p.flat_map { |x| ancestors_of(x).to_a })
  end
  
  # Form transitive reduction

  alias :inner_transitive_reduction :transitive_reduction
  def transitive_reduction
    Taxonomy.new(inner_transitive_reduction)
  end

  def bypass_parent(child, parent)
 
    g = RGL::DirectedAdjacencyGraph.new

    g.add_vertices(*self.vertices)
    g.add_edges(*self.edges)

    direct_parents_of(parent).each do |gp|
      g.add_edge(gp, child)
    end
    
    Taxonomy.new(g)
    
  end

  def bypass_parents(child, parents)
    
    unless parents.empty?
      first, rest = parents.first, parents.drop(1)
      bypass_parent(child, first).bypass_parents(child, rest)
    else
      self
    end
    
  end
  
  def isolate_child_from_one(child, parent)

    unless parents_of(parent).empty?
      
      new_vertex = parent.difference(child)

      g = RGL::DirectedAdjacencyGraph.new

      g.add_vertices(*(vertices - [parent] + [new_vertex]))

      edges.each do |e|
        if e.source == parent
          unless e.target == child
            g.add_edge(new_vertex, e.target)
          end
        elsif e.target == parent
          g.add_edge(e.source, new_vertex)
        else
          g.add_edge(e.source, e.target)
        end
      end
      
      Taxonomy.new(g)
      
    else
      self
    end

  end

  def isolate_child(child, parents)

    unless parents.empty?
      first, rest = parents.first, parents.drop(1)
      isolate_child_from_one(child, first).isolate_child(child, rest)
    else
      self
    end
     
  end
  
  # Recursively merge vertices until the resulting Taxonomy is a tree.
  
  def treeify(count = 0, &block)
    if child = multi_parent_child
      parents = direct_parents_of(child)
      yield(:merging, self, child, parents, count) if block_given?
      count += parents.length
      partition_vertices(child, parents).raise_child(child).treeify(count, &block)
    else
      yield(:merged, nil, nil, nil, count) if block_given?
      self
    end
  end

  # Excise specific vertex.

  def excise_vertex(v)
    g = RGL::DirectedAdjacencyGraph.new
    g.add_vertices(*(vertices - [v]))
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

  include ClassExpression
  
  def setup
    @a1 = Singleton.new('a')
    @a2 = Singleton.new('a')
    @b = Singleton.new('b')
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

  include ClassExpression
  
  def setup
    @a1 = Singleton.new('a')
    @a2 = Singleton.new('a')
    @b = Singleton.new('b')
    @a1c = Complement.new(@a1)
    @a2c = Complement.new(@a2)
    @bc = Complement.new(@b)
    
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
    assert_equal %q{a'}, @a1c.to_s
    assert_equal %q{b'}, @bc.to_s
  end
  
end

class TestDifference < Minitest::Test

  include ClassExpression
  
  def setup
    @a = Singleton.new('a')
    @b = Singleton.new('b')
    @dab1 = Difference.new(@a, @b)
    @dab2 = Difference.new(@a, @b)
    @dba = Difference.new(@b, @a)
  end

  def test_difference_equality
    assert_equal @dab1, @dab2
    refute_equal @dab1, @dba
    refute_equal @dab2, @dba
  end

  def test_difference_to_s
    assert_equal 'a\\b', @dab1.to_s
  end
  
end

class TestUnion < Minitest::Test

  include ClassExpression
  
  def setup
    @a = Singleton.new('a')
    @b = Singleton.new('b')
    @c = Singleton.new('c')
    @aub1 = Union.new([@a, @b])
    @aub2 = Union.new([@a, @b])
    @bua = Union.new([@b, @a])
    @auc = Union.new([@a, @c])
    @aubuc = Union.new([@a, @b, @c])
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
    assert_equal "a\u222ab", @aub2.to_s
  end
  
end

class TestIntersection < Minitest::Test

  include ClassExpression
  
  def setup
    @a = Singleton.new('a')
    @b = Singleton.new('b')
    @c = Singleton.new('c')
    @aib1 = Intersection.new([@a, @b])
    @aib2 = Intersection.new([@a, @b])
    @bia = Intersection.new([@b, @a])
    @aic = Intersection.new([@a, @c])
    @aibic = Intersection.new([@a, @b, @c])
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
    assert_equal "a\u2229b", @aib1.to_s
  end
  
end

class TestOperators < Minitest::Test

  include ClassExpression
  
  def setup
    @s = Singleton.new('a')
    @c = Complement.new(Singleton.new('b'))
    @d = Difference.new(Singleton.new('c'), Singleton.new('d'))
    @u = Union.new(%w{e f g}.map { |k| Singleton.new(k) })
    @i = Intersection.new(%w{h i j}.map { |k| Singleton.new(k) })
  end

  def test_complement
    assert_kind_of Complement, @s.complement
    assert_kind_of Singleton, @c.complement
    assert_kind_of Complement, @d.complement
    assert_kind_of Complement, @u.complement
    assert_kind_of Complement, @i.complement
  end

  def test_difference
    assert_kind_of Difference, @s.difference(@c)
    assert_kind_of Difference, @c.difference(@d)
    assert_kind_of Difference, @d.difference(@u)
    assert_kind_of Difference, @u.difference(@i)
    assert_kind_of Difference, @i.difference(@s)
  end
  
  def test_union
    assert_kind_of Union, @s.union(@c)
    assert_kind_of Union, @c.union(@d)
    assert_kind_of Union, @d.union(@u)
    assert_kind_of Union, @u.union(@i)
    assert_kind_of Union, @i.union(@s)
  end

  def test_intersection
    assert_kind_of Intersection, @s.intersection(@c)
    assert_kind_of Intersection, @c.intersection(@d)
    assert_kind_of Intersection, @d.intersection(@u)
    assert_kind_of Intersection, @u.intersection(@i)
    assert_kind_of Intersection, @i.intersection(@s)
  end
  
end

class TestEmptyTaxonomy < Minitest::Test

  include ClassExpression
  
  def setup
    @t = Taxonomy.new
  end

  def test_tree_operations
    assert_nil @t.multi_parent_child
    tree = @t.treeify
    assert_equal tree, @t
  end
  
end

class TestSingletonTaxonomy < Minitest::Test

  include ClassExpression
  
  def setup
    @t = Taxonomy.new
    @a = Singleton.new('a')
    @t.add_vertex(@a)
  end

  def test_tree_operations
    assert_nil @t.multi_parent_child
    tree = @t.treeify
    assert_equal tree, @t
  end
  
end

class Test3Tree < Minitest::Test

  include ClassExpression
  
  def setup
    edges = %w{a b  a c}
    @vertex_map = edges.uniq.inject({}) { |h, k| h[k] = Singleton.new(k); h }
    @t = Taxonomy[*edges.map { |v| @vertex_map[v] }]
   end

  def test_tree_operations
    c = @vertex_map['c']
    assert_nil @t.multi_parent_child
    
    t1 = @t.excise_vertex(c)
    assert_equal Set.new(t1.vertices), Set.new(@t.vertices - [c])
    assert_equal 1, t1.edges.length
    
    t2 = @t.excise_vertices([c])
    assert_equal Set.new(t2.vertices), Set.new(@t.vertices - [c])
    assert_equal 1, t2.edges.length
    
    t3 = @t.treeify
    assert_equal t3, @t
  end
  
end

class TestDiamondTree < Minitest::Test

  include ClassExpression
  include RGL::Edge
  
  def setup
    edges = %w{a b  a c  b d  c d}
    @vertex_map = edges.uniq.inject({}) { |h, k| h[k] = Singleton.new(k); h }
    @t = Taxonomy[*edges.map { |v| @vertex_map[v] }]

    @a = @vertex_map['a']
    @b = @vertex_map['b']
    @c = @vertex_map['c']
    @d = @vertex_map['d']

    @cdd = @c.difference(@d)
   end

  def test_children
    
    a_children = Set.new(%w{b c}.map { |k| @vertex_map[k] })
    a_descendants = Set.new(%w{b c d}.map { |k| @vertex_map[k] })
    d_parents = Set.new(%w{b c}.map { |k| @vertex_map[k] })
    d_ancestors = Set.new(%w{a b c}.map { |k| @vertex_map[k] })
    
    assert_equal a_children, @t.children_of(@a)
    assert_equal a_children, @t.direct_children_of(@a)
    assert_equal a_descendants, @t.descendants_of(@a)
    
    assert_equal d_parents, @t.parents_of(@d)
    assert_equal d_parents, @t.direct_parents_of(@d)
    assert_equal d_ancestors, @t.ancestors_of(@d)

  end

  def test_excise
    
    assert_equal @d, @t.multi_parent_child

    remaining_vertices = Set.new(@t.vertices - [@a])
    remaining_edges = Set.new(@t.edges.reject { |e| e.source == @a || e.target == @a })
    
    t = @t.excise_vertex(@a)
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges, Set.new(t.edges)

    t = @t.excise_vertices([@a])
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges, Set.new(t.edges)

    remaining_vertices = Set.new(@t.vertices - [@c])
    remaining_edges = Set.new(@t.edges.reject { |e| e.source == @c || e.target == @c })
    added_edges =Set.new([DirectedEdge[@a, @d]])
    
    t = @t.excise_vertex(@c)
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges.union(added_edges), Set.new(t.edges)

    t = @t.excise_vertices([@c])
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges.union(added_edges), Set.new(t.edges)

    remaining_vertices = Set.new(@t.vertices - [@d])
    remaining_edges = Set.new(@t.edges.reject { |e| e.source == @d || e.target == @d })
    
    t = @t.excise_vertex(@d)
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges, Set.new(t.edges)
    
    t = @t.excise_vertices([@d])
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges, Set.new(t.edges)

    remaining_vertices = Set.new(@t.vertices - [@c, @d])
    remaining_edges = Set.new(@t.edges.reject { |e| [@c, @d].include?(e.source) || [@c, @d].include?(e.target) })
    
    t = @t.excise_vertices([@c, @d])
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges, Set.new(t.edges)

  end

  def test_bypass
    
    added_edges = Set.new([DirectedEdge[@a, @d]])
    
    t = @t.bypass_parent(@d, @c)
    assert_equal Set.new(@t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@t.edges).union(added_edges), Set.new(t.edges)
    
    t = @t.bypass_parents(@d, [@c])
    assert_equal Set.new(@t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@t.edges).union(added_edges), Set.new(t.edges)
    
    t = @t.bypass_parents(@d, [@b, @c])
    assert_equal Set.new(@t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@t.edges).union(added_edges), Set.new(t.edges)
    
  end

  def test_isolate

    t = @t.isolate_child_from_one(@d, @c)
    v = Set.new(@t.vertices) - [@c] + [@cdd]
    e = Set.new(@t.edges) - [DirectedEdge[@a, @c], DirectedEdge[@c, @d]] + [DirectedEdge[@a, @cdd]]
    assert_equal v, Set.new(t.vertices)
    assert_equal e, Set.new(t.edges)

    t = @t.isolate_child(@d, [@c])
    assert_equal v, Set.new(t.vertices)
    assert_equal e, Set.new(t.edges)

  end

  def test_bypass_isolate
    t = @t.bypass_parents(@d, [@b, @c]).isolate_child(@d, [@b, @c])
    puts t.edges
  end
  
end

class TestAsymmetricTree < Minitest::Test

  include ClassExpression
  
  def setup
    edges = %w{a b  a c  b e  b f  c g  c h  e i  c i}
    @vertex_map = edges.uniq.inject({}) { |h, k| h[k] = Singleton.new(k); h }
    @t = Taxonomy[*edges.map { |v| @vertex_map[v] }]
    after_bypass_edges = %w{a b  a c  b e  b f  c g  c h  e i  c i  a i  b i}
    @after_bypass_t = Taxonomy[*after_bypass_edges.map { |v| @vertex_map[v] }]
    @c, @e, @i = *%w{c e i}.map { |k| @vertex_map[k] }
  end

  def test_bypass
    t = @t.bypass_parents(@i, [@c, @e])
    assert_equal Set.new(@after_bypass_t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_t.edges), Set.new(t.edges)
  end
  
end
