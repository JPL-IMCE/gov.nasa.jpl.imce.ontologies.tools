require 'rgl/adjacency'
require 'rgl/transitivity'
require 'rgl/topsort'
require 'delegate'

module ClassExpression
  class Simple < String
  end
  class Singleton < Simple
  end
  class Complement < Simple
    def to_s
      'Complement(' + super + ')'
    end
  end
  class Complex < Set
    def to_s
      '(' + to_a.join(',') + ')'
    end
  end
  class Union < Complex
    def to_s
      'union' + super
    end
    def union(s)
      self.dup << s
    end
  end
  class Intersection < Complex
    def to_s
      'intersection' + super
    end
    def intersection(s)
      self.dup << s
    end
    def difference(s)
      self.dup << Complement(s)
    end
  end

  def complement(s)
    Complement.new(s)
  end
  def union(s)
    Union.new(self.dup << s)
  end
  def intersection(s)
    Intersection.new(self.dup << s)
  end
  def difference(s)
    intersection(complement(s))
  end
end

module SimpleClassExpression < String
end

class SingletonClassExpression < SimpleClassExpression
end

class ComplementClassExpression < SimpleClassExpression
end

module ComplexClassExpression < Set
end

class UnionClassExpression < Set
  def to_s
    'Union' + super
  end
end

class IntersectionClassExpression < Set
  def to_s
    'Intersection' + super
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
