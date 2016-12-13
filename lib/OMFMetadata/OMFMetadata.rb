module OMFMetadata
  
  require 'owlapi'
  require 'jgrapht-core-0.9.0.jar'
  
  java_import 'uk.ac.manchester.cs.owl.owlapi.OWLClassImpl'
  java_import 'uk.ac.manchester.cs.owl.owlapi.OWLDataPropertyImpl'
  java_import 'uk.ac.manchester.cs.owl.owlapi.OWLObjectPropertyImpl'
  
  java_import 'org.jgrapht.experimental.dag.DirectedAcyclicGraph'
  java_import 'org.jgrapht.graph.DefaultEdge'
  java_import 'org.jgrapht.alg.TransitiveClosure'
  
  class Instance
    
    attr_reader :manager, :ontology, :format, :terminology_graphs, :graph_extensions, :graph_nestings
    
    # Map OWLAPI objects to their corresponding OMFMetadata objects.
    
    @@registry = {}
      
    def initialize(io, logger = nil)
      
      @logger = logger
      
      # Create ontology manager.
        
      @manager = OWLManager.createOWLOntologyManager
      raise "couldn't create owl ontology manager" unless manager
    
      # Load input ontology.
      
      @ontology = manager.loadOntologyFromOntologyDocument(io.to_inputstream)
      raise "couldn't load metadata ontology" unless @ontology
      
      # Get ontology format.
      
      @format = manager.getOntologyFormat(@ontology)
      raise "couldn't get ontology format" unless @format
        
      # Populate maps.
      
      @@registry.merge!(@concept_subclasses = get_individuals('tbox:EntityConceptSubclassAxiom', EntityConceptSubclassAxiom))
      @@registry.merge!(@aspect_subclasses = get_individuals('tbox:EntityDefinitionAspectSubclassAxiom', EntityDefinitionAspectSubclassAxiom))
      @@registry.merge!(@relationship_subclasses = get_individuals('tbox:EntityReifiedRelationshipSubclassAxiom', EntityReifiedRelationshipSubclassAxiom))
      @@registry.merge!(@aspects = get_individuals('tbox:ModelEntityAspect', ModelEntityAspect))
      @@registry.merge!(@concepts = get_individuals('tbox:ModelEntityConcept', ModelEntityConcept))
      @@registry.merge!(@relationships = get_individuals('tbox:ModelEntityReifiedRelationship', ModelEntityReifiedRelationship))
      @@registry.merge!(@scalar_types = get_individuals('tbox:ModelScalarDataType', ModelScalarDataType))
      @@registry.merge!(@scalar_types = get_individuals('tbox:ModelStructuredDataType', ModelStructuredDataType))
      @@registry.merge!(@terminology_graphs = get_individuals('tbox:ModelTerminologyGraph', ModelTerminologyGraph))
      @@registry.merge!(@graph_extensions = get_individuals('tbox:TerminologyGraphDirectExtensionAxiom', TerminologyGraphDirectExtensionAxiom))
      @@registry.merge!(@graph_nestings = get_individuals('tbox:TerminologyGraphDirectNestingAxiom', TerminologyGraphDirectNestingAxiom))
      @@registry.freeze
      
    end
   
    private
    
    def get_individuals(prop_name, klass)
      ce = create_class(prop_name)
      @ontology.getClassAssertionAxioms(ce).inject({}) do |m, g|
        i = g.getIndividual
        m[i] = klass.new(self, i)
        m
      end
    end
  
    public
    
    def registry
      @@registry
    end

    def location_map(graphs, path_prefix, entailments, entailments_path_prefix, path_suffix)
      graphs.inject({}) do |map, graph|
        o_iri = graph.uri_provenance
        f_iri = graph.file_iri(path_prefix, path_suffix)
        map[o_iri] = f_iri
        entailments.each do |type|
          eo_iri = "#{o_iri}/#{type}"
          ef_iri = graph.file_iri(entailments_path_prefix, path_suffix, type)
          map[eo_iri] = ef_iri
        end
        map
      end
    end
    
    def imports_graph(graphs, &block)
      g = graphs.inject(DirectedAcyclicGraph.new(DefaultEdge)) do |memo, graph|
        memo.addVertex(graph)
        graph.imports.each do |import|
          unless block_given? && !yield(import)
            memo.addVertex(import)
            memo.addEdge(graph, import)
          end
        end
        memo
      end
      TransitiveClosure::INSTANCE.closeSimpleDirectedGraph(g)
      g
    end
    
    def imports_map(graph)
      result = {}
      iter = graph.iterator
      while iter.hasNext
        source = iter.next
        result[source] = graph.edgesOf(source).map do |e|
          graph.getEdgeTarget(e)
        end.reject do |target|
          target == source
        end
      end
      result
    end

    def create_class(string)
      OWLClassImpl.new(@format.getIRI(string))
    end
    
    def create_data_property(string)
      OWLDataPropertyImpl.new(@format.getIRI(string))
    end
    
    def data_property_values(subject, predicate)
      @ontology.getDataPropertyAssertionAxioms(subject).select do |o|
        o.getProperty == predicate
      end.map { |a| a.getObject.getLiteral }
    end
    
    def data_property_value(subject, predicate)
      data_property_values(subject, predicate).first
    end
    
    def create_object_property(string)
      OWLObjectPropertyImpl.new(@format.getIRI(string))
    end
  
    def object_property_values(subject, predicate)
      @ontology.getObjectPropertyAssertionAxioms(subject).select do |o|
        o.getProperty == predicate
      end.map { |a| a.getObject }
    end
    
    def object_property_value(subject, predicate)
      object_property_values(subject, predicate).first
    end
    
  end
  
  class OMFMetadataClass
    
    attr_reader :metadata, :individual
    
    def initialize(metadata, individual)
      @metadata = metadata
      @individual = individual
    end

  end
  
  class ModelTerminologyGraph < OMFMetadataClass
    
    def mutable?
      prop = @metadata.create_data_property('tbox:kind')
      @metadata.data_property_value(@individual, prop) == 'mutable'
    end
    
    def kind_provenance
      prop = @metadata.create_data_property('tbox:exportedOTIPackageKindProvenance')
      @metadata.data_property_value(@individual, prop)
    end
   
    def uri_provenance
      prop = @metadata.create_data_property('tbox:exportedOTIPackageURIProvenance')
      @metadata.data_property_value(@individual, prop)
    end

    def relative_filename
      prop = @metadata.create_data_property('tbox:hasRelativeFilename')
      @metadata.data_property_value(@individual, prop)
    end

    def hash_prefix
      prop = @metadata.create_data_property('tbox:hasRelativeIRIHashPrefix')
      @metadata.data_property_value(@individual, prop)
    end
   
    def hash_suffix
      prop = @metadata.create_data_property('tbox:hasRelativeIRIHashSuffix')
      @metadata.data_property_value(@individual, prop)
    end
   
    def iri_path
      prop = @metadata.create_data_property('tbox:hasRelativeIRIPath')
      @metadata.data_property_value(@individual, prop)
    end
   
    def imports
      relationships = {
        :graph_extensions => [ 'tbox:hasDirectExtendingChild', 'tbox:hasDirectExtendedParent' ],
        :graph_nestings => [ 'tbox:hasDirectNestedChild', 'tbox:hasDirectNestingParent' ]
      }
      relationships.inject([]) do |memo, rel|
        axioms, prop = *rel
        importer = @metadata.create_object_property(prop[0])
        imported = @metadata.create_object_property(prop[1])
        memo += @metadata.send(axioms).keys.select do |e|
          @individual.getIRI == @metadata.object_property_value(e, importer).getIRI
        end.map do |a|
          v = @metadata.object_property_value(a, imported)
          raise "no #{imported} value for #{a}" unless v
          g = @metadata.terminology_graphs[v]
          raise "no terminology graph for #{v}" unless g
          g
        end
        memo
      end
    end
    
    def file_path(path_prefix, path_suffix, entailments_type = nil)
      e_str = entailments_type.nil? ? '' : "/#{entailments_type}"
      case kp = kind_provenance
      when 'OTIProfile', 'OTIModelLibrary', 'OTIMetamodel', 'W3C'
        "#{path_prefix}/#{relative_filename}#{e_str}#{path_suffix}"
      when 'OMFGraphOntology'
        "#{path_prefix}/#{iri_path}#{e_str}#{path_suffix}"
      else
        raise "invalid kind provenance (#{kp}) for #{uri_provenance} (#{self.individual.getIRI.to_string})"
      end
    end
    
    def file_iri(path_prefix = nil, path_suffix = nil, entailments_type = nil)
      file_path('file://' + path_prefix, path_suffix, entailments_type)
    end
  
    def ontology_iri
      uri_provenance
    end
    
    def entailments_iri(type)
      "#{ontology_iri}/#{type}"
    end
    
    def ontologies_prefix=(p)
      @ontologies_prefix = p
    end
    
    def entailments_prefix=(p)
      @entailments_prefix = p
    end
    
    def tests_prefix=(p)
      @tests_prefix = p
    end
    
    def ontologies_suffix=(s)
      @ontologies_suffix = s
    end
    
    def tests_suffix=(s)
      @tests_suffix = s
    end
    
    def ontology_file
      file_path(@ontologies_prefix, @ontologies_suffix)
    end
    
    def entailments_file(type)
      file_path(@entailments_prefix, @ontologies_suffix, type)
    end
    
    def test_file
      file_path(@tests_prefix, @tests_suffix)
    end
    
    def sentinels_prefix=(p)
      @sentinels_prefix = p
    end
    
    def ontology_sentinel
      file_path(@sentinels_prefix, @ontologies_suffix)
    end
    
    def entailments_sentinel(type)
      file_path(@sentinels_prefix, @ontologies_suffix, type)
    end
    
    def audits_prefix=(p)
      @audits_prefix = p
    end
    
    def audits_file
      file_path(@audits_prefix, @tests_suffix)
    end
    
    def definitions
      prop = @metadata.create_object_property('tbox:directlyDefinesTypeTerm')
      @metadata.object_property_values(@individual, prop).map do |d|
        @metadata.registry[d]
      end
    end
    
  end
  
  class TerminologyGraphDirectExtensionAxiom < OMFMetadataClass
  end
  
  class TerminologyGraphDirectNestingAxiom < OMFMetadataClass
  end
  
  class EntityConceptSubclassAxiom < OMFMetadataClass
  end
    
  class EntityDefinitionAspectSubclassAxiom < OMFMetadataClass
  end
    
  class EntityReifiedRelationshipSubclassAxiom < OMFMetadataClass
  end
    
  class ModelEntityAspect < OMFMetadataClass
  end
    
  class ModelEntityConcept < OMFMetadataClass
  end
    
  class ModelEntityReifiedRelationship < OMFMetadataClass
  end
    
  class ModelScalarDataType < OMFMetadataClass
  end
    
  class ModelStructuredDataType < OMFMetadataClass
  end
    
end