require 'graph'
gem 'minitest'
require 'minitest/autorun'

class TestGraph < MiniTest::Test

  def setup
    c = %w{
            Thing Concept Aspect Component Flow Interface Item Mission
            PerformingElement SpecifiedElement TraversingElement
            ReifiedObjectProperty Performs Specifies Traverses
          }
    u = c.inject({}) do |m, o|
      m[o] = Union.new([Klass.new(o)])
      m
    end
    @mt = Graph.new
    [['Thing', 'Concept'], ['Thing', 'Aspect'], ['Thing', 'ReifiedObjectProperty'],
     ['Concept', 'Component'], ['Concept', 'Flow'], ['Concept', 'Interface'],
     ['Concept', 'Item'], ['Concept', 'Mission'],
     ['Aspect', 'PerformingElement'], ['Aspect', 'SpecifiedElement'], ['Aspect', 'TraversingElement'],
     ['PerformingElement', 'Component'], ['PerformingElement', 'Mission'],
     ['SpecifiedElement', 'Component'], ['SpecifiedElement', 'Interface'], ['SpecifiedElement', 'Mission'],
     ['TraversingElement', 'Flow'], ['TraversingElement', 'Item'],
     ['ReifiedObjectProperty', 'Performs'], ['ReifiedObjectProperty', 'Specifies'],
     ['ReifiedObjectProperty', 'Traverses'],
    ].each do |pair|
      @mt.add_edge(u[pair[0]], u[pair[1]])
    end
  end
 
  def test_to_s
    g1 = Graph.new
    assert_equal "Graph {\n}", g1.to_s

    g2 = Graph.new
    g2.add_edge(Union.new([Klass.new('Thing')]), Union.new([Klass.new('Concept')]))
    assert_equal "Graph {\nUnion(Class(Thing)) -> Union(Class(Concept))\n}", g2.to_s

    s = "Graph {\n" +
        "Union(Class(Thing)) -> Union(Class(Concept))\n" +
	"Union(Class(Thing)) -> Union(Class(Aspect))\n" +
	"Union(Class(Thing)) -> Union(Class(ReifiedObjectProperty))\n" +
	"Union(Class(Concept)) -> Union(Class(Component))\n" +
	"Union(Class(Concept)) -> Union(Class(Interface))\n" +
	"Union(Class(Concept)) -> Union(Class(Mission))\n" +
	"Union(Class(Aspect)) -> Union(Class(PerformingElement))\n" +
	"Union(Class(Aspect)) -> Union(Class(SpecifiedElement))\n" +
	"Union(Class(ReifiedObjectProperty)) -> Union(Class(Performs))\n" +
	"Union(Class(ReifiedObjectProperty)) -> Union(Class(Specifies))\n" +
	"Union(Class(PerformingElement)) -> Union(Class(Component))\n" +
	"Union(Class(PerformingElement)) -> Union(Class(Mission))\n" +
	"Union(Class(SpecifiedElement)) -> Union(Class(Component))\n" +
	"Union(Class(SpecifiedElement)) -> Union(Class(Interface))\n" +
	"Union(Class(SpecifiedElement)) -> Union(Class(Mission))\n" +
	"}"
    assert_equal s, @mt.to_s
  end

  def test_multi_parent_child
    assert_equal 'Union(Class(Component))', @mt.multi_parent_child.to_s
  end

  def test_parents_of
    s = %w{Concept PerformingElement SpecifiedElement}.map do |c|
      Union.new([Klass.new(c)])
    end
    assert_equal s, @mt.parents_of(@mt.multi_parent_child)
  end

  def test_merge_vertices
    m = @mt.merge_vertices(@mt.parents_of(@mt.multi_parent_child))
    s = "Graph {\n" +
	"Union(Class(Concept),Class(PerformingElement),Class(SpecifiedElement)) -> Union(Class(Component))\n" +
	"Union(Class(Concept),Class(PerformingElement),Class(SpecifiedElement)) -> Union(Class(Interface))\n" +
	"Union(Class(Concept),Class(PerformingElement),Class(SpecifiedElement)) -> Union(Class(Mission))\n" +
	"Union(Class(Aspect)) -> Union(Class(Concept),Class(PerformingElement),Class(SpecifiedElement))\n" +
        "Union(Class(ReifiedObjectProperty)) -> Union(Class(Performs))\n" +
        "Union(Class(ReifiedObjectProperty)) -> Union(Class(Specifies))\n" +
	"Union(Class(Thing)) -> Union(Class(Aspect))\n" +
	"Union(Class(Thing)) -> Union(Class(ReifiedObjectProperty))\n" +
        "}"
    assert_equal s, m.to_s
  end

  def test_treeify
    t = @mt.treeify
    s = ''
    assert_equal s, t.to_s
  end

  def test_sibling_groups
    gs = @mt.treeify.sibling_groups
    s = ''
    assert_equal s, gs.map { |g| g.map { |s| s.to_s } }
  end
  
end
