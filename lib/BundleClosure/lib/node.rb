require 'union'

class Node

  def initialize(u = Union.new())
    @union = u
    @children = Set.new
    @parents = Set.new
  end

  attr_reader :union, :children, :parents

  def eql?(o)
    @union.eql?(o.union)
  end

  alias :== :eql?
  
  def add_child(c)
    @children.add(c)
  end

  def add_children(e)
    @children.merge(e)
  end
  
  def delete_child(c)
    @children.delete(c)
  end
  
  def delete_children(e)
    @children.subtract(e)
  end
  
  def clear_children
    @children.clear
  end
  
  def add_parent(c)
    @parents.add(c)
  end

  def add_parents(e)
    @parents.merge(e)
  end
  
  def delete_parent(c)
    @parents.delete(c)
  end

  def delete_parents(e)
    @parents.subtract(e)
  end

  def clear_parents
    @parents.clear
  end
  
  def to_s
    "Node(#{@union.to_s})"
  end

  def traverse(&block)
    yield self
    @children.each do |c|
      c.traverse(&block)
    end
  end

  def descendants
    @descendants ||= get_descendants
  end

  private

  def get_descendants
    @children.inject(Set.new) do |m, c|
      m << c
      m += c.descendants
      m
    end
  end
  
end
