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
      s.inject(java.util.HashSet.new) do |l, e|
        l << e.to_owl_class_expression(factory)
        l
      end
    end

  end
  
  class Intersection

    def to_owl_class_expression(factory)
      factory.getOWLObjectIntersectionOf(to_expression_list(factory))
    end
    
  end

  class Union

    def to_owl_class_expression(factory)
      factory.getOWLObjectUnionOf(to_expression_list(factory))
    end
    
  end

end
