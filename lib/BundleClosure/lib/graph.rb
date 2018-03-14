require 'node'

class Graph

  def initialize(r = Node.new(Union.new([Klass.new('A')])))
    @root = r
    @node = {}
    add_node(r)
  end

  def to_s
    s = []
    s << 'Graph {'
    s << '}'
    s.join("\n")
  end
  
  def traverse(&block)
    @root.traverse(&block)
  end

  def add_node(n)
    @node[n.union] = n unless @node.contains?(n.union)
  end
  
  def self.parse(io)
    io.each_line do |l|
    end
  end
  
end
