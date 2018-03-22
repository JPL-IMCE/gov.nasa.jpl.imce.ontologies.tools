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
    topsort_iterator.to_a.reverse.detect do |c|
      edges.select { |e| e.target == c }.length > 1
    end
  end

  def parents_of(c)
    edges.select { |e| e.target == c }.map { |e| e.source }
  end

  def merge_vertices(s)
    new_vertex = Union.new(s.inject(Set.new) { |m, o| m = m.union(o.classes) })

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
    
    Graph.new(g.transitive_reduction)
  end

  def treeify
    if c = multi_parent_child
      merge_vertices(parents_of(c)).treeify
    else
      self
    end
  end

  def sibling_groups
    vertices.map do |v|
      edges.select { |e| e.source == v }.map { |e| e.target }
    end.select do |g|
      g.length > 1
    end
  end
  
end
