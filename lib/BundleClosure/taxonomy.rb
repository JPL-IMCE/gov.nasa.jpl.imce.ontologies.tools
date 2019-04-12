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
      self == o ? self :
        Intersection === o ? o.intersection(self) : super(o)
    end
    def union(o)
      self == o ? self :
        Union === o ? o.union(self) : super(o)
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
  
  def treeify_with_bypass_reduce_isolate(count = 0, &block)
    if child = multi_parent_child
      parents = parents_of(child)
      yield(:treeifying, self, child, parents, count) if block_given?
      count += parents.length
      bp = bypass_parents(child, parents)
      rd = bp.reduce_child(child)
      rd.isolate_child(child, parents).treeify_with_bypass_reduce_isolate(count, &block)
    else
      yield(:treeified, nil, nil, nil, count) if block_given?
      self
    end
  end

  # Recursively merge vertices until the resulting Taxonomy is a tree.

  def treeify_with_merge(count = 0, &block)
    if child = multi_parent_child
      parents = parents_of(child)
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
