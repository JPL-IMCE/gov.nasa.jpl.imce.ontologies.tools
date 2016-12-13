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
#    Constants for IMCE ontology management conventions. 
#
#++

module IMCE
  
  DEFAULT_IMPORTS_FILE = nil
  DEFAULT_ENTAILMENT_TYPES = 'ClassEntailments,PropertyEntailments'
  DEFAULT_LOG4J_CONFIG_FILE = nil
  DEFAULT_PREFIX_FILE = nil

  ANNOTATION_IRI = 'http://imce.jpl.nasa.gov/foundation/annotation/annotation'
  
  EMBEDDING_STRING = '-embedding'
  METAMODEL_STRING = '-metamodel'
  VIEW_STRING = '-view'
  
  WWW_OMG_ORG = 'http://imce.jpl.nasa.gov/www.omg.org'
  WWW_OMG_ORG_ES = Regexp.escape(WWW_OMG_ORG)
  WWW_OMG_ORG_RE = Regexp.new(WWW_OMG_ORG_ES)
  WWW_OMG_ORG_SPARQL_RE = WWW_OMG_ORG_ES.gsub(/\\/, '\\\\\\')
  
  WWW_W3_ORG = 'http://www.w3.org'
  WWW_W3_ORG_ES = Regexp.escape(WWW_W3_ORG)
  WWW_W3_ORG_RE = Regexp.new(WWW_W3_ORG_ES)
  WWW_W3_ORG_SPARQL_RE = WWW_W3_ORG_ES.gsub(/\\/, '\\\\\\')
  
  IMCE_JPL_NASA_GOV = 'http:\/\/imce\.jpl\.nasa\.gov/(foundation|discipline|application)'
  IMCE_JPL_NASA_GOV_RE = Regexp.new(IMCE_JPL_NASA_GOV)
  IMCE_JPL_NASA_GOV_SPARQL_RE = IMCE_JPL_NASA_GOV.gsub(/\\/, '\\\\\\')
  
  PURL_ORG = 'http://purl.org/dc/elements'
  PURL_ORG_ES = Regexp.escape(PURL_ORG)
  PURL_ORG_RE = Regexp.new(PURL_ORG_ES)
  PURL_ORG_SPARQL_RE = PURL_ORG_ES.gsub(/\\/, '\\\\\\')
  
  OWL2_MOF2 = 'http://imce.jpl.nasa.gov/foundation/owl2-mof2/owl2-mof2'
  OWL2_MOF2_ES = Regexp.escape(OWL2_MOF2)
  OWL2_MOF2_RE = Regexp.new(OWL2_MOF2_ES)
  OWL2_MOF2_SPARQL_RE = OWL2_MOF2_ES.gsub(/\\/, '\\\\\\')
  
end