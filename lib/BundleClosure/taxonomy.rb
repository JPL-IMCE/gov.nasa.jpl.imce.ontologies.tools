require 'rgl/adjacency'
require 'rgl/transitivity'
require 'rgl/topsort'
require 'delegate'

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
    vertices.detect { |v| direct_parents_of(v).length > 1 }
  end

  # Find children of a vertex.
  
  def children_of(v)
    edges.select { |e| e.source == v }.map { |e| e.target }
  end

  # Find descendants of a vertex.
  
  def descendants_of(v, key = Random.rand(1000))
    warn "descendants_of([#{v.to_a.join(',')}], #{key})"
    if (c = children_of(v)).empty?
      []
    else
      c + c.flat_map { |x| descendants_of(x, key) }
    end
  end

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
    warn "ancestors_of([#{v.to_a.join(',')}], #{key})"
    if (p = parents_of(v)).empty?
      []
    else
      p + p.flat_map { |x| ancestors_of(x, key) }
    end
  end

  def direct_parents_of(v)
    p = parents_of(v)
    p - p.flat_map { |x| ancestors_of(x) }
  end
  
  # Form transitive reduction

  alias :inner_transitive_reduction :transitive_reduction
  def transitive_reduction
    Taxonomy.new(inner_transitive_reduction)
  end
  
  # Create a new Taxonomy with the specified vertices merged into a
  # single vertex.
  
  def merge_vertices(s)
warn "merge: [#{s.map { |p| p.to_s }.join(',')}]"
    new_vertex = s.inject(Union.new){ |m, o| m = m.union(o); m }

    g = RGL::DirectedAdjacencyGraph.new
    pl = Set.new
    cl = Set.new
    edges.each do |edge|
      source_in_s = s.include?(edge.source)
      target_in_s = s.include?(edge.target)
      if source_in_s && target_in_s
        # do nothing
      elsif source_in_s
        cl << edge.target
      elsif target_in_s
        pl << edge.source
      else
        g.add_edge(edge.source, edge.target)
      end
    end
warn "pl before: [#{pl.map { |p| p.to_s }.join(',')}]"
    pl -= pl.flat_map { |p| ancestors_of(p) }
warn "pl after: [#{pl.map { |p| p.to_s }.join(',')}]"
warn "cl before: [#{cl.map { |p| p.to_s }.join(',')}]"
    cl -= cl.flat_map { |c| descendants_of(c) }
warn "cl after: [#{cl.map { |p| p.to_s }.join(',')}]"

    pl.each do |p|
      g.add_edge(p, new_vertex)
    end
    cl.each do |c|
      g.add_edge(new_vertex, c)
    end

    raise "cyclic" unless acyclic?
    Taxonomy.new(g)
  end

  # Recursively merge vertices until the resulting Taxonomy is a tree.
  
  def treeify(count = 0, &block)
    if child = multi_parent_child
      parents = direct_parents_of(child)
      yield(:merging, self, child, parents, count) if block_given?
      count += parents.length
      merge_vertices(parents).treeify(count, &block)
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

  # Excise all vertices that include a match to a given pattern.

  def excise(pattern, count = 0, &block)
    if m = vertices.detect { |v| v.any? { |x| x =~ pattern } }
      count += 1
      yield :excising, m, count if block_given?
      excise_vertex(m).excise(pattern, count, &block)
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
    warn "top_vertices #{top_vertices.map { |v| v.to_a.join(',') }}"
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
