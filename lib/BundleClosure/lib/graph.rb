require 'node'

class Graph

  def initialize(r = Node.new(Union.new([Klass.new('A')])))
    @root = r
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
  
end
