require 'union'

class Node

  def initialize(u = Union.new())
    @union = u
    @children = Set.new
    @parents = Set.new
  end

  attr_reader :union, :children, :parents
  
  def add_child(c)
    @children.add(c)
  end

  def delete_child(c)
    @children.delete(c)
  end
  
  def add_parent(c)
    @parents.add(c)
  end

  def delete_parent(c)
    @parents.delete(c)
  end
  
  def to_s
    "Node(#{@union.to_s})"
  end
  
end
