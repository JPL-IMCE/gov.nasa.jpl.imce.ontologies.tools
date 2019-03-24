require 'minitest/autorun'

require 'taxonomy'

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
    tree = @t.treeify_with_bypass_reduce_isolate
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
    tree = @t.treeify_with_bypass_reduce_isolate
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
    
    t4 = @t.treeify_with_bypass_reduce_isolate
    assert_equal t4, @t
  end
  
end

class TestDiamondTree < Minitest::Test

  include ClassExpression
  include RGL::Edge
  
  def setup
    initial_edges = %w{a b  a c  b d  c d}
    @vertex_map = initial_edges.uniq.inject({}) { |h, k| h[k] = Singleton.new(k); h }
    @initial_tree = Taxonomy[*initial_edges.map { |v| @vertex_map[v] }]

    @a = @vertex_map['a']
    @b = @vertex_map['b']
    @c = @vertex_map['c']
    @d = @vertex_map['d']

    @bdd = @vertex_map['b\\d'] = @b.difference(@d)
    @cdd = @vertex_map['c\\d'] = @c.difference(@d)

    @buc = @vertex_map['buc'] = @b.union(@c)

    after_merge_edges = %w{a buc  buc d}
    @after_merge_tree = Taxonomy[*after_merge_edges.map { |v| @vertex_map[v] }]

    after_bypass_edges = %w{a b  a c  a d}
    @after_bypass_tree = Taxonomy[*after_bypass_edges.map { |v| @vertex_map[v] }]

    @after_bypass_reduce_tree = @after_bypass_tree

    after_bypass_reduce_isolate_c_edges = %w{a b  a c\\d  a d}
    @after_bypass_reduce_isolate_c_tree = Taxonomy[*after_bypass_reduce_isolate_c_edges.map { |v| @vertex_map[v] }]
    
    after_bypass_reduce_isolate_edges = %w{a b\\d  a c\\d  a d}
    @after_bypass_reduce_isolate_tree = Taxonomy[*after_bypass_reduce_isolate_edges.map { |v| @vertex_map[v] }]
   end

  def test_children
    
    a_children = Set.new(%w{b c}.map { |k| @vertex_map[k] })
    a_descendants = Set.new(%w{b c d}.map { |k| @vertex_map[k] })
    d_parents = Set.new(%w{b c}.map { |k| @vertex_map[k] })
    d_ancestors = Set.new(%w{a b c}.map { |k| @vertex_map[k] })
    
    assert_equal a_children, @initial_tree.children_of(@a)
    assert_equal a_children, @initial_tree.direct_children_of(@a)
    assert_equal a_descendants, @initial_tree.descendants_of(@a)
    
    assert_equal d_parents, @initial_tree.parents_of(@d)
    assert_equal d_parents, @initial_tree.direct_parents_of(@d)
    assert_equal d_ancestors, @initial_tree.ancestors_of(@d)

  end

  def test_excise
    
    assert_equal @d, @initial_tree.multi_parent_child

    remaining_vertices = Set.new(@initial_tree.vertices - [@a])
    remaining_edges = Set.new(@initial_tree.edges.reject { |e| e.source == @a || e.target == @a })
    
    t = @initial_tree.excise_vertex(@a)
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges, Set.new(t.edges)

    t = @initial_tree.excise_vertices([@a])
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges, Set.new(t.edges)

    remaining_vertices = Set.new(@initial_tree.vertices - [@c])
    remaining_edges = Set.new(@initial_tree.edges.reject { |e| e.source == @c || e.target == @c })
    added_edges =Set.new([DirectedEdge[@a, @d]])
    
    t = @initial_tree.excise_vertex(@c)
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges.union(added_edges), Set.new(t.edges)

    t = @initial_tree.excise_vertices([@c])
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges.union(added_edges), Set.new(t.edges)

    remaining_vertices = Set.new(@initial_tree.vertices - [@d])
    remaining_edges = Set.new(@initial_tree.edges.reject { |e| e.source == @d || e.target == @d })
    
    t = @initial_tree.excise_vertex(@d)
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges, Set.new(t.edges)
    
    t = @initial_tree.excise_vertices([@d])
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges, Set.new(t.edges)

    remaining_vertices = Set.new(@initial_tree.vertices - [@c, @d])
    remaining_edges = Set.new(@initial_tree.edges.reject { |e| [@c, @d].include?(e.source) || [@c, @d].include?(e.target) })
    
    t = @initial_tree.excise_vertices([@c, @d])
    assert_equal remaining_vertices, Set.new(t.vertices)
    assert_equal remaining_edges, Set.new(t.edges)

  end

  def test_merge

    t = @initial_tree.merge_vertices([@b, @c])
    assert_equal Set.new(@after_merge_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_merge_tree.edges), Set.new(t.edges)
    
  end

  def test_treeify_with_merge

    t = @initial_tree.treeify_with_merge
    assert_equal Set.new(@after_merge_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_merge_tree.edges), Set.new(t.edges)
 
  end

  def test_sibling_map_with_merge

    d = @initial_tree.treeify_with_merge.sibling_map
    assert_empty d
    
  end
  
  def test_bypass
    
    ad = DirectedEdge[@a, @d]
    bd = DirectedEdge[@b, @d]
    cd = DirectedEdge[@c, @d]
    
    t = @initial_tree.bypass_parent(@d, @c)
    assert_equal Set.new(@initial_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@initial_tree.edges << ad) - [cd], Set.new(t.edges)
    
    t = @initial_tree.bypass_parents(@d, [@c])
    assert_equal Set.new(@initial_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@initial_tree.edges << ad) - [cd], Set.new(t.edges)
    
    t = @initial_tree.bypass_parents(@d, [@b, @c])
    assert_equal Set.new(@after_bypass_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_tree.edges), Set.new(t.edges)
    
  end

  def test_reduce
    
    t = @after_bypass_tree.reduce_child(@d)
    assert_equal Set.new(@after_bypass_reduce_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_reduce_tree.edges), Set.new(t.edges)
    
  end
  
  def test_isolate

    t = @after_bypass_reduce_tree.isolate_child_from_one(@d, @c)
    assert_equal Set.new(@after_bypass_reduce_isolate_c_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_reduce_isolate_c_tree.edges), Set.new(t.edges)

    t = @after_bypass_reduce_tree.isolate_child(@d, [@b, @c])
    assert_equal Set.new(@after_bypass_reduce_isolate_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_reduce_isolate_tree.edges), Set.new(t.edges)

  end

  def test_bypass_reduce_isolate
    
    t = @initial_tree.bypass_parents(@d, [@b, @c]).reduce_child(@d).isolate_child(@d, [@b, @c])
    assert_equal Set.new(@after_bypass_reduce_isolate_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_reduce_isolate_tree.edges), Set.new(t.edges)
  end
  

  def test_treeify_with_bypass_reduce_isolate
    
    t = @initial_tree.treeify_with_bypass_reduce_isolate
    assert_equal Set.new(@after_bypass_reduce_isolate_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_reduce_isolate_tree.edges), Set.new(t.edges)
    
  end
  
  def test_sibling_map_with_bypass_reduce_isolate

    d = @initial_tree.treeify_with_bypass_reduce_isolate.sibling_map
    map = { @a => Set.new([ @bdd, @cdd, @d ]) }
    assert_equal map, d
    
  end
  
end

class Test8SymmetricTree < Minitest::Test

  include ClassExpression
  
  def setup
    initial_edges = %w{a b  a c  b d  b e  c f  c g  d h  g h}
    @vertex_map = initial_edges.uniq.inject({}) { |h, k| h[k] = Singleton.new(k); h }
    @initial_tree = Taxonomy[*initial_edges.map { |v| @vertex_map[v] }]

    @a, @b, @c, @d, @e, @f, @g, @h = *%w{a b c d e f g h}.map { |k| @vertex_map[k] }
    @buc = @vertex_map['buc'] = @b.union(@c)
    @dug = @vertex_map['dug'] = @d.union(@g)
    @bdh = @vertex_map['b\\h'] = @b.difference(@h)
    @cdh = @vertex_map['c\\h'] = @c.difference(@h)
    @ddh = @vertex_map['d\\h'] = @d.difference(@h)
    @gdh = @vertex_map['g\\h'] = @g.difference(@h)

    after_merge_edges = %w{a b  a c  b dug  b e  c dug  c f  dug h}
    @after_merge_tree = Taxonomy[*after_merge_edges.map { |v| @vertex_map[v] }]

    after_treeify_with_merge_edges = %w{a buc  buc dug  buc e  buc f  dug h}
    @after_treeify_with_merge_tree = Taxonomy[*after_treeify_with_merge_edges.map { |v| @vertex_map[v] }]
    @after_treeify_with_merge_map = { @buc => Set.new([@e, @dug, @f]) }

    after_bypass_edges = %w{a b  a c  b d  b e  b h  c f  c g  c h}
    @after_bypass_tree = Taxonomy[*after_bypass_edges.map { |v| @vertex_map[v] }]

    @after_bypass_reduce_tree = @after_bypass_tree

    after_bypass_reduce_isolate_edges = %w{a b  a c  b d\\h  b e  b h  c f  c g\\h  c h}
    @after_bypass_reduce_isolate_tree = Taxonomy[*after_bypass_reduce_isolate_edges.map { |v| @vertex_map[v] }]

    after_treeify_with_bypass_reduce_isolate_edges = %w{a b\\h  a c\\h  a h  b\\h d\\h  b\\h e  c\\h f  c\\h g\\h}
    @after_treeify_with_bypass_reduce_isolate_t = Taxonomy[*after_treeify_with_bypass_reduce_isolate_edges.map { |v| @vertex_map[v] }]
    @after_treeify_with_bypass_reduce_isolate_map = { @a => Set.new([@bdh, @cdh, @h]), @bdh => Set.new([@ddh, @e]), @cdh => Set.new([@f, @gdh]) }
  end

  def test_merge 
    t = @initial_tree.merge_vertices([@d, @g])
    assert_equal Set.new(@after_merge_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_merge_tree.edges), Set.new(t.edges)
  end
  
  def test_treeify_with_merge
    t = @initial_tree.treeify_with_merge
    assert_equal Set.new(@after_treeify_with_merge_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_treeify_with_merge_tree.edges), Set.new(t.edges)
  end

  def test_sibling_map_with_merge
    map = @after_treeify_with_merge_tree.sibling_map
    assert_equal @after_treeify_with_merge_map, map
  end

  def test_bypass
    t = @initial_tree.bypass_parents(@h, [@d, @g])
    assert_equal Set.new(@after_bypass_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_tree.edges), Set.new(t.edges)
  end
  
  def test_reduce
    t = @after_bypass_tree.reduce_child(@h)
    assert_equal Set.new(@after_bypass_reduce_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_reduce_tree.edges), Set.new(t.edges)
  end

  def test_isolate
    t = @after_bypass_reduce_tree.isolate_child(@h, [@d, @g])
    assert_equal Set.new(@after_bypass_reduce_isolate_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_reduce_isolate_tree.edges), Set.new(t.edges)
  end
  
  def test_treeify_with_bypass_reduce_isolate
    t = @initial_tree.treeify_with_bypass_reduce_isolate
    assert_equal Set.new(@after_treeify_with_bypass_reduce_isolate_t.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_treeify_with_bypass_reduce_isolate_t.edges), Set.new(t.edges)
  end
  
  def test_sibling_map_with_bypass_reduce_isolate
    map = @after_treeify_with_bypass_reduce_isolate_t.sibling_map
    assert_equal @after_treeify_with_bypass_reduce_isolate_map, map
  end

end

class TestAsymmetricTree < Minitest::Test

  include ClassExpression
  
  def setup
    initial_edges = %w{a b  a c  b d  b e  c f  c g  c i  e h  e i  i j}
    @vertex_map = initial_edges.uniq.inject({}) { |h, k| h[k] = Singleton.new(k); h }
    @initial_tree = Taxonomy[*initial_edges.map { |v| @vertex_map[v] }]
    
    @a, @b, @c, @d, @e, @f, @g, @h, @i = *%w{a b c d e f g h i}.map { |k| @vertex_map[k] }
    @cue = @vertex_map['cue'] = @c.union(@e)
    @bdi = @vertex_map['b\\i'] = @b.difference(@i)
    @cdi = @vertex_map['c\\i'] = @c.difference(@i)
    @edi = @vertex_map['e\\i'] = @e.difference(@i)

    after_merge_edges = %w{a b  b d  b cue  i j  cue f  cue g  cue i  cue h}
    @after_merge_tree = Taxonomy[*after_merge_edges.map { |v| @vertex_map[v] }]

    @after_treeify_with_merge_tree = @after_merge_tree
    
    @after_treeify_with_merge_map = {
      @b => Set.new([@cue, @d]),
      @cue => Set.new([@f, @g, @h, @i])
    }
    
    after_bypass_edges = %w{a b  a c  a i  b d  b e  b i  c f  c g  e h  i j}
    @after_bypass_tree = Taxonomy[*after_bypass_edges.map { |v| @vertex_map[v] }]
    
    after_bypass_reduce_edges = %w{a b  a c  b d  b e  b i  c f  c g  e h  i j}
    @after_bypass_reduce_tree = Taxonomy[*after_bypass_reduce_edges.map { |v| @vertex_map[v] }]
    
    after_bypass_reduce_isolate_edges = %w{a b  a c\\i  b d  b i  b e\\i  c\\i f  c\\i g  e\\i h  i j}
    @after_bypass_reduce_isolate_tree = Taxonomy[*after_bypass_reduce_isolate_edges.map { |v| @vertex_map[v] }]

    @after_treeify_with_bypass_reduce_isolate_tree = @after_bypass_reduce_isolate_tree

    @after_treeify_with_bypass_reduce_isolate_map = {
      @a => Set.new([@b, @cdi]),
      @b => Set.new([@d, @edi, @i]),
      @cdi => Set.new([@f, @g])
    }
    
  end

  def test_acyclic?
    assert @initial_tree.acyclic?
  end
  
  def test_merge
    
    t = @initial_tree.merge_vertices([@c, @e])
    assert_equal Set.new(@after_merge_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_merge_tree.edges), Set.new(t.edges)
    
  end
  
  def test_treeify_with_merge

    t = @initial_tree.treeify_with_merge
    assert_equal Set.new(@after_treeify_with_merge_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_treeify_with_merge_tree.edges), Set.new(t.edges)
    
  end

  def test_sibling_map_with_merge

    m = @after_treeify_with_merge_tree.sibling_map
    assert_equal(@after_treeify_with_merge_map, m)

  end
  
  def test_bypass
    
    t = @initial_tree.bypass_parents(@i, [@c, @e])
    assert_equal Set.new(@after_bypass_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_tree.edges), Set.new(t.edges)
    
  end

  def test_reduce
    
    t = @after_bypass_tree.reduce_child(@i)
    assert_equal Set.new(@after_bypass_reduce_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_reduce_tree.edges), Set.new(t.edges)

  end
  
  def test_isolate
    
    t = @after_bypass_reduce_tree.isolate_child(@i, [@c, @e])
    assert_equal Set.new(@after_bypass_reduce_isolate_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_bypass_reduce_isolate_tree.edges), Set.new(t.edges)
    
  end

  def test_treeify_with_bypass_reduce_isolate
    
    t = @initial_tree.treeify_with_bypass_reduce_isolate
    assert_equal Set.new(@after_treeify_with_bypass_reduce_isolate_tree.vertices), Set.new(t.vertices)
    assert_equal Set.new(@after_treeify_with_bypass_reduce_isolate_tree.edges), Set.new(t.edges)

  end

  def test_sibling_map_with_bypass_reduce_isolate
    m = @after_bypass_reduce_isolate_tree.sibling_map
    assert_equal @after_treeify_with_bypass_reduce_isolate_map, m
  end
  
end
