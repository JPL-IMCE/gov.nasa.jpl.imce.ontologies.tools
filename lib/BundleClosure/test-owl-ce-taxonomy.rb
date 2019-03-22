require 'minitest/autorun'

require 'owl-ce-taxonomy'

class TestSingletonOwlCE < Minitest::Test

  include ClassExpression

  def setup
    @factory = OWLDataFactoryImpl.new
    @name = 'a'
    @a = Singleton.new(@name)
  end

  def test_owl_class_expression
    ce = @a.to_owl_class_expression(@factory)
    assert_kind_of org.semanticweb.owlapi.model.OWLClass, ce
    assert_equal @name, ce.getIRI.toString
  end

end

class TestComplementOwlCE < Minitest::Test

  include ClassExpression

  def setup
    @factory = OWLDataFactoryImpl.new
    @name = 'a'
    @ac = Singleton.new(@name).complement
  end

  def test_owl_class_expression
    ce = @ac.to_owl_class_expression(@factory)
    assert_kind_of org.semanticweb.owlapi.model.OWLObjectComplementOf, ce
    op = ce.getOperand
    assert_kind_of org.semanticweb.owlapi.model.OWLClass, op
    assert_equal @name, op.getIRI.toString
  end

end

class TestDifferenceOwlCE < Minitest::Test

  include ClassExpression

  def setup
    @factory = OWLDataFactoryImpl.new
    @aname = 'a'
    @bname = 'b'
    @a = Singleton.new(@aname)
    @b = Singleton.new(@bname)
    @amb = @a.difference(@b)
  end

  def test_owl_class_expression
    ce = @amb.to_owl_class_expression(@factory)
    assert_kind_of org.semanticweb.owlapi.model.OWLObjectIntersectionOf, ce
    ops = ce.getOperands
    assert_equal 2, ops.length
    aops = ops.select { |o| org.semanticweb.owlapi.model.OWLClass === o }
    assert_equal @aname, aops.first.getIRI.toString
    assert_equal 1, aops.length
    bops = ops.select { |o| org.semanticweb.owlapi.model.OWLObjectComplementOf === o }
    assert_equal 1, bops.length
    op = bops.first.getOperand
    assert_kind_of org.semanticweb.owlapi.model.OWLClass, op
    assert_equal @bname, op.getIRI.toString
  end

end

class TestIntersectionOwlCE < Minitest::Test

  include ClassExpression

  def setup
    @factory = OWLDataFactoryImpl.new
    @aname = 'a'
    @bname = 'b'
    @cname = 'c'
    @aibicc = Singleton.new(@aname).
                intersection(Singleton.new(@bname)).
                intersection(Singleton.new(@cname))
  end

  def test_owl_class_expression
    ce = @aibicc.to_owl_class_expression(@factory)
    assert_kind_of org.semanticweb.owlapi.model.OWLObjectIntersectionOf, ce
    ops = ce.getOperands
    ops.each do |op|
      assert_kind_of org.semanticweb.owlapi.model.OWLClass, op
    end
    names = Set.new(ops.map { |op| op.getIRI.toString })
    assert_equal Set.new([@aname, @bname, @cname]), names
  end

end

class TestUnionOwlCE < Minitest::Test

  include ClassExpression

  def setup
    @factory = OWLDataFactoryImpl.new
    @aname = 'a'
    @bname = 'b'
    @cname = 'c'
    @aibicc = Singleton.new(@aname).
                union(Singleton.new(@bname)).
                union(Singleton.new(@cname))
  end

  def test_owl_class_expression
    ce = @aibicc.to_owl_class_expression(@factory)
    assert_kind_of org.semanticweb.owlapi.model.OWLObjectUnionOf, ce
    ops = ce.getOperands
    ops.each do |op|
      assert_kind_of org.semanticweb.owlapi.model.OWLClass, op
    end
    names = Set.new(ops.map { |op| op.getIRI.toString })
    assert_equal Set.new([@aname, @bname, @cname]), names
  end

end
