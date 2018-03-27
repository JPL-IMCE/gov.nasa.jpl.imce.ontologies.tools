require 'rgl/adjacency'
require 'rgl/transitivity'
require 'rgl/topsort'
require 'delegate'

class Graph < DelegateClass(RGL::DirectedAdjacencyGraph)

  def initialize(g = RGL::DirectedAdjacencyGraph.new)
    super(g)
  end
  
  def to_s
    s = []
    s << 'Graph {'
    edges.each do |e|
      s << "#{e.source.to_s} -> #{e.target.to_s}"
    end
    s << '}'
    s.join("\n")
  end

  def multi_parent_child
    count = Hash.new { |h, k| h[k] = 0 }
    edges.each do |edge|
      t = edge.target
      return t if count[t] == 1
      count[t] += 1
    end
    nil
  end

  def parents_of(c)
    edges.select { |e| e.target == c }.map { |e| e.source }
  end

  def merge_vertices(s)
    new_vertex = s.inject(Set.new){ |m, o| m = m.union(o) }

    g = RGL::DirectedAdjacencyGraph.new
    edges.each do |edge|
      source_in_s = s.include?(edge.source)
      target_in_s = s.include?(edge.target)
      if source_in_s && target_in_s
        # do nothing
      elsif source_in_s
        g.add_edge(new_vertex, edge.target)
      elsif target_in_s
        g.add_edge(edge.source, new_vertex)
      else
        g.add_edge(edge.source, edge.target)
      end
    end
    
    Graph.new(g)
  end

  def treeify(count = 0, &block)
    if child = multi_parent_child
      parents = parents_of(child)
      yield(:merging, child, parents, count) if block_given?
      count += parents.length
      merge_vertices(parents).treeify(count, &block)
    else
      yield(:merged, nil, nil, count) if block_given?
      Graph.new(transitive_reduction)
    end
  end

  def root_at(root)
    g = RGL::DirectedAdjacencyGraph.new
    edges.each do |edge|
      g.add_edge(edge.source, edge.target)
    end
    top_vertices = g.edges.inject(Set.new(g.vertices)) do |set, edge|
      set.delete(edge.target)
      set
    end
    top_vertices.each do |v|
      g.add_edge(root, v)
    end
    Graph.new(g)
  end
  
  def sibling_groups
    vertices.map do |v|
      edges.select { |e| e.source == v }.map { |e| e.target }
    end.select do |g|
      g.length > 1
    end
  end
  
end
