require 'owlapi-distribution-3.4.5.jar'
require 'taxonomy'

java_import 'uk.ac.manchester.cs.owl.owlapi.OWLDataFactoryImpl'
java_import org.semanticweb.owlapi.model.IRI
java_import 'org.semanticweb.owlapi.model.ClassExpressionType'

module ClassExpression

  class Singleton
    def to_owl_class_expression(factory)
      factory.getOWLClass(IRI.create(name))
    end
  end

  class Complement
    def to_owl_class_expression(factory)
      op = s.to_owl_class_expression(factory)
      factory.getOWLObjectComplementOf(op)
    end
  end

  class Difference

    def to_owl_class_expression(factory)
      s = a.to_owl_class_expression(factory)
      m = b.to_owl_class_expression(factory)
      factory.getOWLObjectIntersectionOf(s, factory.getOWLObjectComplementOf(m))
    end
    
  end

  class NAry

    def to_expression_list(factory)
      expression.s.inject(java.util.HashSet.new) do |l, e|
        l << e.to_owl_class_expression(factory)
        l
      end
    end

  end
  
  class Intersection

    def to_owl_class_expression(factory)
      factory.getObjectIntersectionOf(s.to_expression_list(factory))
    end
    
  end

  class Union

    def to_owl_class_expression(factory)
      factory.getObjectUnionOf(s.to_expression_list(factory))
    end
    
  end

end

require 'minitest/autorun'

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
