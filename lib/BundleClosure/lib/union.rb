require 'set'

class Union

  def initialize(e = [])
    @classes = Set.new(e)
  end

  def <<(k)
    @classes << k
  end
  
  attr_reader :classes
  
  def eql?(o)
    classes.eql?(o.classes)
  end

  alias :== :eql?
  
  def to_s
    "Union(#{classes.map { |e| e.to_s }.join(',')})"
  end
  
end
