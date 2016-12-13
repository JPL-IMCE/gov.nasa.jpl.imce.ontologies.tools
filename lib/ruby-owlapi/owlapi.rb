#--
#
#    $HeadURL$
#
#    $LastChangedRevision$
#    $LastChangedDate$
#
#    $LastChangedBy$
#
#    Copyright (c) 2008-2014 California Institute of Technology.
#    All rights reserved.
#
#    Jena module for accessing OWL API vi JRuby.
#
#++

require 'owlapi-distribution-3.4.5.jar'

java_import org.coode.owlapi.manchesterowlsyntax.ManchesterOWLSyntaxOntologyFormat
java_import org.coode.owlapi.turtle.TurtleOntologyFormat
java_import org.semanticweb.owlapi.apibinding.OWLManager
java_import org.semanticweb.owlapi.io.OWLOntologyDocumentTarget
java_import org.semanticweb.owlapi.io.OWLXMLOntologyFormat
java_import org.semanticweb.owlapi.io.RDFXMLOntologyFormat
java_import org.semanticweb.owlapi.io.StreamDocumentTarget
java_import org.semanticweb.owlapi.io.StringDocumentSource
java_import org.semanticweb.owlapi.io.StringDocumentTarget
java_import org.semanticweb.owlapi.io.SystemOutDocumentTarget
java_import org.semanticweb.owlapi.model.AddAxiom
java_import org.semanticweb.owlapi.model.AddOntologyAnnotation
java_import org.semanticweb.owlapi.model.IRI
java_import org.semanticweb.owlapi.model.MissingImportHandlingStrategy
java_import org.semanticweb.owlapi.model.OWLAnnotation
java_import org.semanticweb.owlapi.model.OWLAnnotationProperty
java_import org.semanticweb.owlapi.model.OWLAxiom
java_import org.semanticweb.owlapi.model.OWLClass
java_import org.semanticweb.owlapi.model.OWLClassAssertionAxiom
java_import org.semanticweb.owlapi.model.OWLClassExpression
java_import org.semanticweb.owlapi.model.OWLDataExactCardinality
java_import org.semanticweb.owlapi.model.OWLDataFactory
java_import org.semanticweb.owlapi.model.OWLDataProperty
java_import org.semanticweb.owlapi.model.OWLDataPropertyAssertionAxiom
java_import org.semanticweb.owlapi.model.OWLDataPropertyRangeAxiom
java_import org.semanticweb.owlapi.model.OWLDataRange
java_import org.semanticweb.owlapi.model.OWLDataSomeValuesFrom
java_import org.semanticweb.owlapi.model.OWLDataUnionOf
java_import org.semanticweb.owlapi.model.OWLDatatype
java_import org.semanticweb.owlapi.model.OWLDatatypeDefinitionAxiom
java_import org.semanticweb.owlapi.model.OWLDatatypeRestriction
java_import org.semanticweb.owlapi.model.OWLDeclarationAxiom
java_import org.semanticweb.owlapi.model.OWLDifferentIndividualsAxiom
java_import org.semanticweb.owlapi.model.OWLDisjointClassesAxiom
java_import org.semanticweb.owlapi.model.OWLEntity
java_import org.semanticweb.owlapi.model.OWLEquivalentClassesAxiom
java_import org.semanticweb.owlapi.model.OWLFacetRestriction
java_import org.semanticweb.owlapi.model.OWLFunctionalDataPropertyAxiom
java_import org.semanticweb.owlapi.model.OWLIndividual
java_import org.semanticweb.owlapi.model.OWLLiteral
java_import org.semanticweb.owlapi.model.OWLNamedIndividual
java_import org.semanticweb.owlapi.model.OWLObjectAllValuesFrom
java_import org.semanticweb.owlapi.model.OWLObjectExactCardinality
java_import org.semanticweb.owlapi.model.OWLObjectHasValue
java_import org.semanticweb.owlapi.model.OWLObjectIntersectionOf
java_import org.semanticweb.owlapi.model.OWLObjectOneOf
java_import org.semanticweb.owlapi.model.OWLObjectProperty
java_import org.semanticweb.owlapi.model.OWLObjectPropertyAssertionAxiom
java_import org.semanticweb.owlapi.model.OWLObjectPropertyExpression
java_import org.semanticweb.owlapi.model.OWLObjectSomeValuesFrom
java_import org.semanticweb.owlapi.model.OWLOntology
java_import org.semanticweb.owlapi.model.OWLOntologyCreationException
java_import org.semanticweb.owlapi.model.OWLOntologyFormat
java_import org.semanticweb.owlapi.model.OWLOntologyID
java_import org.semanticweb.owlapi.model.OWLOntologyIRIMapper
java_import org.semanticweb.owlapi.model.OWLOntologyLoaderConfiguration
java_import org.semanticweb.owlapi.model.OWLOntologyManager
java_import org.semanticweb.owlapi.model.OWLOntologyStorageException
java_import org.semanticweb.owlapi.model.OWLSubClassOfAxiom
java_import org.semanticweb.owlapi.model.OWLSubObjectPropertyOfAxiom
java_import org.semanticweb.owlapi.model.PrefixManager
java_import org.semanticweb.owlapi.model.SWRLAtom
java_import org.semanticweb.owlapi.model.SWRLObjectPropertyAtom
java_import org.semanticweb.owlapi.model.SWRLRule
java_import org.semanticweb.owlapi.model.SWRLVariable
java_import org.semanticweb.owlapi.model.SetOntologyID
java_import org.semanticweb.owlapi.reasoner.BufferingMode
java_import org.semanticweb.owlapi.reasoner.ConsoleProgressMonitor
java_import org.semanticweb.owlapi.reasoner.InferenceType
java_import org.semanticweb.owlapi.reasoner.Node
java_import org.semanticweb.owlapi.reasoner.NodeSet
java_import org.semanticweb.owlapi.reasoner.OWLReasoner
java_import org.semanticweb.owlapi.reasoner.OWLReasonerConfiguration
java_import org.semanticweb.owlapi.reasoner.OWLReasonerFactory
java_import org.semanticweb.owlapi.reasoner.SimpleConfiguration
java_import org.semanticweb.owlapi.reasoner.structural.StructuralReasoner
java_import org.semanticweb.owlapi.reasoner.structural.StructuralReasonerFactory
java_import org.semanticweb.owlapi.util.AutoIRIMapper
java_import org.semanticweb.owlapi.util.DefaultPrefixManager
java_import org.semanticweb.owlapi.util.InferredAxiomGenerator
java_import org.semanticweb.owlapi.util.InferredOntologyGenerator
java_import org.semanticweb.owlapi.util.InferredSubClassAxiomGenerator
java_import org.semanticweb.owlapi.util.OWLClassExpressionVisitorAdapter
java_import org.semanticweb.owlapi.util.OWLEntityRemover
java_import org.semanticweb.owlapi.util.OWLOntologyMerger
java_import org.semanticweb.owlapi.util.OWLOntologyWalker
java_import org.semanticweb.owlapi.util.OWLOntologyWalkerVisitor
java_import org.semanticweb.owlapi.util.SimpleIRIMapper
java_import org.semanticweb.owlapi.vocab.OWL2Datatype
java_import org.semanticweb.owlapi.vocab.OWLFacet
java_import org.semanticweb.owlapi.vocab.OWLRDFVocabulary

module OWLAPI
end