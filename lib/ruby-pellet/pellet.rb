#--
#
#    $HeadURL: https://sscae-cm.jpl.nasa.gov/svn/ontologies/trunk/gov.nasa.jpl.imce.ontologies/lib/ruby-jena/jena.rb $
#
#    $LastChangedRevision: 3602 $
#    $LastChangedDate: 2014-02-04 15:17:34 -0800 (Tue, 04 Feb 2014) $
#
#    $LastChangedBy: sjenkins $
#
#    Copyright (c) 2008-2014 California Institute of Technology.
#    All rights reserved.
#
#    Jena module for accessing Pellet API vi JRuby.
#
#++

require 'java'

require 'antlr/antlr-runtime-3.2.jar'
require 'aterm-java-1.6.jar'
require 'jaxb/jaxb-api.jar'
require 'jena/arq-2.8.7.jar'
require 'jena/icu4j-3.4.4.jar'
require 'jena/iri-0.8.jar'
require 'jena/jena-2.6.4.jar'
require 'jena/junit-4.5.jar'
require 'jena/log4j-1.2.13.jar'
require 'jena/lucene-core-2.3.1.jar'
#Require 'jena/slf4j-api-1.5.8.jar'
#Require 'jena/slf4j-log4j12-1.5.8.jar'
require 'jena/stax-api-1.0.1.jar'
require 'jena/wstx-asl-3.2.9.jar'
require 'jena/xercesImpl-2.7.1.jar'
require 'jetty/commons-logging-api.jar'
require 'jetty/jetty.jar'
require 'jgrapht/jgrapht-jdk1.5.jar'
require 'junit/junit.jar'
#require 'owlapi/owlapi-bin.jar'
#require 'owlapi/owlapi-src.jar'
require 'owlapiv3/owlapi-bin.jar'
require 'owlapiv3/owlapi-src.jar'
require 'pellet-cli.jar'
require 'pellet-core.jar'
require 'pellet-datatypes.jar'
require 'pellet-dig.jar'
require 'pellet-el.jar'
require 'pellet-explanation.jar'
require 'pellet-jena.jar'
require 'pellet-modularity.jar'
require 'pellet-owlapi.jar'
require 'pellet-owlapiv3.jar'
require 'pellet-pellint.jar'
require 'pellet-query.jar'
require 'pellet-rules.jar'
require 'pellet-test.jar'
require 'servlet.jar'
require 'xsdlib/relaxngDatatype.jar'
require 'xsdlib/xsdlib.jar'

java_import org.semanticweb.owlapi.model.IRI  
java_import org.semanticweb.owlapi.util.SimpleIRIMapper