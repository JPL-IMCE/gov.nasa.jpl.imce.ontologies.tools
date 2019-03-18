require 'rgl/adjacency'
require 'rgl/topsort'
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
    def intersection(o)
      (o == self) ? self : super(o)
    end
    def union(o)
      (o == self) ? self : super(o)
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
    def initialize(s = [])
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

# A Taxonomy is a directed graph of class expressions.

class Taxonomy < DelegateClass(RGL::DirectedAdjacencyGraph)

  def initialize(g = RGL::DirectedAdjacencyGraph.new)
    super(g)
  end

  def self.[](*a)
    Taxonomy.new((RGL::DirectedAdjacencyGraph[*a]))
  end

  # Find a vertex with multiple parents. Returns nil if none.
  
  def multi_parent_child
    each_vertex.detect { |v| parents_of(v).length > 1 }
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

  def merge_vertices(s)
    
    new_vertex = s.inject(ClassExpression::Union.new){ |m, o| m = m.union(o); m }

    g = RGL::DirectedAdjacencyGraph.new
    parent_list = Set.new
    child_list = Set.new
    
    g.add_vertices(*(Set.new(vertices) - s + [new_vertex]))
    
    edges.each do |edge|
      source_in_s = s.include?(edge.source)
      target_in_s = s.include?(edge.target)
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

    direct_parents = parent_list - parent_list.flat_map { |p| ancestors_of(p).to_a }
    direct_children = child_list - child_list.flat_map { |c| descendants_of(c).to_a }

    direct_parents.each do |p|
      g.add_edge(p, new_vertex)
    end
    direct_children.each do |c|
      g.add_edge(new_vertex, c)
    end

    Taxonomy.new(g)
  end

  def bypass_parent(child, parent)
 
    g = RGL::DirectedAdjacencyGraph.new

    g.add_vertices(*self.vertices)

    edges.each do |e|
      g.add_edge(e.source, e.target) unless [e.source, e.target] == [parent, child]
    end

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

  def reduce_child(child)

    g = RGL::DirectedAdjacencyGraph.new

    g.add_vertices(*self.vertices)

    edges.each do |e|
      g.add_edge(e.source, e.target) unless e.target == child
    end

    direct_parents_of(child).each do |p|
      g.add_edge(p, child)
    end

    Taxonomy.new(g)
    
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
  
  # Recursively bypass and isolate vertices until the resulting Taxonomy is a tree.
  
  def treeify_with_bypass_isolate(count = 0, &block)
    if child = multi_parent_child
      parents = direct_parents_of(child)
      yield(:treeifying, self, child, parents, count) if block_given?
      count += parents.length
      bp = bypass_parents(child, parents)
      rd = bp.reduce_child(child)
      rd.isolate_child(child, parents_of(child)).treeify_with_bypass_isolate(count, &block)
    else
      yield(:treeified, nil, nil, nil, count) if block_given?
      self
    end
  end

  # Recursively merge vertices until the resulting Taxonomy is a tree.

  def treeify_with_merge(count = 0, &block)
    if child = multi_parent_child
      parents = direct_parents_of(child)
      yield(:treeifying, self, child, parents, count) if block_given?
      count += parents.length
      merge_vertices(parents).treeify_with_merge(count, &block)
    else
      yield(:treeified, nil, nil, nil, count) if block_given?
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
    if m = vertices.detect { |v| v.to_s =~ pattern }
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

  # Return a hash mapping parents to sibling children.
  
  def sibling_map
    vertices.inject({}) do |m, v|
      cl = edges.select { |e| e.source == v }.map { |e| e.target }
      m[v] = Set.new(cl) if cl.length > 1
      m
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
    tree = @t.treeify_with_merge
    assert_equal tree, @t
    tree = @t.treeify_with_bypass_isolate
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
    tree = @t.treeify_with_merge
    assert_equal tree, @t
    tree = @t.treeify_with_bypass_isolate
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
    
    t3 = @t.treeify_with_merge
    assert_equal t3, @t
    
    t4 = @t.treeify_with_bypass_isolate
    assert_equal t4, @t
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

    @bdd = @b.difference(@d)
    @cdd = @c.difference(@d)

    @buc = @b.union(@c)
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

  def test_merge

    t = @t.merge_vertices([@b, @c])
    a_buc = DirectedEdge[@a, @buc]
    buc_d = DirectedEdge[@buc, @d]
    assert_equal Set.new([@a, @buc, @d]), Set.new(t.vertices)
    assert_equal Set.new([a_buc, buc_d]), Set.new(t.edges)
    
  end

  def test_treeify_with_merge

    t = @t.treeify_with_merge
    a_buc = DirectedEdge[@a, @buc]
    buc_d = DirectedEdge[@buc, @d]
    assert_equal Set.new([@a, @buc, @d]), Set.new(t.vertices)
    assert_equal Set.new([a_buc, buc_d]), Set.new(t.edges)
 
  end

  def test_sibling_map_with_merge

    d = @t.treeify_with_merge.sibling_map
    assert_empty d
    
  end
  
  def test_bypass
    
    ad = DirectedEdge[@a, @d]
    bd = DirectedEdge[@b, @d]
    cd = DirectedEdge[@c, @d]
    
    t = @t.bypass_parent(@d, @c)
    assert_equal Set.new(@t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@t.edges << ad) - [cd], Set.new(t.edges)
    
    t = @t.bypass_parents(@d, [@c])
    assert_equal Set.new(@t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@t.edges << ad) - [cd], Set.new(t.edges)
    
    t = @t.bypass_parents(@d, [@b, @c])
    assert_equal Set.new(@t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@t.edges << ad) - [bd, cd], Set.new(t.edges)
    
  end

  def test_reduce
    t1 = @t.bypass_parents(@d, [@b, @c])
    t2 = t1.reduce_child(@d)
    assert_equal Set.new(t1.vertices), Set.new(t2.vertices)
    assert_equal Set.new(t1.edges), Set.new(t2.edges)
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
    v = Set.new(@t.vertices) - [@b, @c] + [@bdd, @cdd]
    e = Set.new([DirectedEdge[@a, @bdd], DirectedEdge[@a, @cdd]] + [DirectedEdge[@a, @d]])
    assert_equal v, Set.new(t.vertices)
    assert_equal e, Set.new(t.edges)
  end
  

  def test_treeify_with_bypass_isolate
    
    t = @t.treeify_with_bypass_isolate
    v = Set.new(@t.vertices) - [@b, @c] + [@bdd, @cdd]
    e = Set.new([DirectedEdge[@a, @bdd], DirectedEdge[@a, @cdd]] + [DirectedEdge[@a, @d]])
    assert_equal v, Set.new(t.vertices)
    assert_equal e, Set.new(t.edges)
    
  end
  
  def test_sibling_map_with_bypass_isolate

    d = @t.treeify_with_bypass_isolate.sibling_map
    map = { @a => Set.new([ @bdd, @cdd, @d ]) }
    assert_equal map, d
    
  end
  
end

class Test8SymmetricTree < Minitest::Test

  include ClassExpression
  
  def setup
    edges = %w{a b  a c  b d  b e  c f  c g  d h  g h}
    @vertex_map = edges.uniq.inject({}) { |h, k| h[k] = Singleton.new(k); h }
    @t = Taxonomy[*edges.map { |v| @vertex_map[v] }]
    @b, @c, @d, @e, @f, @g, @h = *%w{b c d e f g h}.map { |k| @vertex_map[k] }
    @buc = @vertex_map['buc'] = @b.union(@c)
    @dug = @vertex_map['dug'] = @d.union(@g)
    @bdh = @vertex_map['b\\h'] = @b.difference(@h)
    @cdh = @vertex_map['c\\h'] = @c.difference(@h)
    @ddh = @vertex_map['d\\h'] = @d.difference(@h)
    @gdh = @vertex_map['g\\h'] = @g.difference(@h)

    after_treeify_with_merge_edges = %w{a buc  buc dug  buc e  buc f  dug h}
    @after_treeify_with_merge_t = Taxonomy[*after_treeify_with_merge_edges.map { |v| @vertex_map[v] }]
    @after_treeify_with_merge_map = { @buc => Set.new([@e, @dug, @f]) }

    after_treeify_with_bi_edges = %w{a b\\h  a c\\h  a h  b\\h d\\h  b\\h e  c\\h f  c\\h g\\h}
    @after_treeify_with_bi_t = Taxonomy[*after_treeify_with_bi_edges.map { |v| @vertex_map[v] }]
  end

  def test_treeify_with_merge
    t = @t.treeify_with_merge
    assert_equal Set.new(@after_treeify_with_merge_t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_treeify_with_merge_t.edges), Set.new(t.edges)
  end

  def test_sibling_map_with_merge
    map = @after_treeify_with_merge_t.sibling_map
    assert_equal @after_treeify_with_merge_map, map
  end

  def test_treeify_with_bypass_isolate
    t = @t.treeify_with_bypass_isolate
    assert_equal Set.new(@after_treeify_with_bi_t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_treeify_with_bi_t.edges), Set.new(t.edges)
  end
  
end

class TestAsymmetricTree < Minitest::Test

  include ClassExpression
  
  def setup
    edges = %w{a b  a c  b d  b e  c f  c g  c i  e h  e i  i j}
    @vertex_map = edges.uniq.inject({}) { |h, k| h[k] = Singleton.new(k); h }
    @t = Taxonomy[*edges.map { |v| @vertex_map[v] }]
    @b, @c, @e, @i = *%w{b c e i}.map { |k| @vertex_map[k] }
    @cue = @vertex_map['cue'] = @c.union(@e)
    @bdi = @vertex_map['b\\i'] = @b.difference(@i)
    @cdi = @vertex_map['c\\i'] = @c.difference(@i)
    @edi = @vertex_map['e\\i'] = @e.difference(@i)

    after_merge_edges = %w{a b  b d  b cue  i j  cue f  cue g  cue i  cue h}
    @after_merge_t = Taxonomy[*after_merge_edges.map { |v| @vertex_map[v] }]
    
    after_bypass_edges = %w{a b  a c  a i  b d  b e  b i  c f  c g  e h  i j}
    @after_bypass_t = Taxonomy[*after_bypass_edges.map { |v| @vertex_map[v] }]
    
    after_isolate_edges = %w{a b  a c\\i  b d  b e\\i  c\\i f  c\\i g  e\\i h  i j}
    @after_isolate_t = Taxonomy[*after_isolate_edges.map { |v| @vertex_map[v] }]

    after_bypass_isolate_edges = %w{a b  a c\\i  a i  b d  b i  b e\\i  c\\i f  c\\i g e\\i h  i j}
    @after_bypass_isolate_t = Taxonomy[*after_bypass_isolate_edges.map { |v| @vertex_map[v] }]

    after_treeify_with_bi_edges = %w{a b\\i  a c\\i  a i  b\\i d  b\\i e\\i  c\\i f  c\\i g  e\\i h  i j}
    @after_treeify_with_bi_t = Taxonomy[*after_treeify_with_bi_edges.map { |v| @vertex_map[v] }]
  end

  def test_acyclic?
    assert @t.acyclic?
  end
  
  def test_merge
    
    t = @t.merge_vertices([@c, @e])
    assert_equal Set.new(@after_merge_t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_merge_t.edges), Set.new(t.edges)
    
  end
  
  def test_treeify_with_merge

    t = @t.treeify_with_merge
    assert_equal Set.new(@after_merge_t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_merge_t.edges), Set.new(t.edges)
    
  end
  
  def test_bypass
    
    t = @t.bypass_parents(@i, [@c, @e])
    assert_equal Set.new(@after_bypass_t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_t.edges), Set.new(t.edges)
    
  end

  def test_isolate
    
    t = @t.isolate_child(@i, [@c, @e])
    assert_equal Set.new(@after_isolate_t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_isolate_t.edges), Set.new(t.edges)
    
  end

  def test_bypass_isolate
    
    t = @t.bypass_parents(@i, [@c, @e]).isolate_child(@i, [@c, @e])
    assert_equal Set.new(@after_bypass_isolate_t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_isolate_t.edges), Set.new(t.edges)
    
  end
  
  def test_treeify_with_bypass_isolate
    
    t = @t.treeify_with_bypass_isolate
    v1 = Set.new(@after_treeify_with_bi_t.vertices.map { |v| v.to_s })
    v2 = Set.new(t.vertices.map { |v| v.to_s })
    assert_equal v1, v2
    assert_equal Set.new(@after_treeify_with_bi_t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_treeify_with_bi_t.edges), Set.new(t.edges)

  end
  
end
