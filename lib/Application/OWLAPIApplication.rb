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
#    Adaptation of Application library for use with OWL API. 
#
#++

require 'Application'

class OWLAPIApplication < Application
  
  require 'owlapi'
  require 'imce'
  require 'yaml'
  
  include OWLAPI
  include IMCE
  
  DEFAULT_LOCATION_MAPPING = 'location-mapping.yaml'
  
  BUILTIN_NAMESPACES = {
    'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    'rdfs' => 'http://www.w3.org/2000/01/rdf-schema#',
    'owl' => 'http://www.w3.org/2002/07/owl#',
    'xsd' => 'https://www.w3.org/2001/XMLSchema#',
    'xml' => 'http://www.w3.org/XML/1998/namespace',
    'dc' => 'http://purl.org/dc/elements/1.1/',
    'swrl' => 'http://www.w3.org/2003/11/swrl#',
    'swrlb' => 'http://www.w3.org/2003/11/swrlb#',
  }

  def run
    
    add_options
    
    super
    
    # Configure logger.
    
    PropertyConfigurator.configure(@options.log4j_config_file) if @options.log4j_config_file
    
    @namespace_by_prefix = get_namespaces

  end
  
  def add_options
    
    @options.location_mapping = DEFAULT_LOCATION_MAPPING
    option_parser.on('--location-mapping FILE', 'location mapping file') do |v|
      @options.location_mapping = v
    end
    @options.prefix_file = DEFAULT_PREFIX_FILE
    option_parser.on('--prefix-file FILE', "prefix file (#{DEFAULT_PREFIX_FILE})") do |v|
      @options.prefix_file = v
    end

  end
  
  # Get namespace definitions.

  def get_namespaces
    log(INFO, 'get namespace definitions')
    if @options.prefix_file
      namespace_by_prefix = YAML.load(File.open(@options.prefix_file))
    else
      namespace_by_prefix = {}
    end
    log(DEBUG, "namespace_by_prefix: #{namespace_by_prefix.inspect}")
    namespace_by_prefix.merge(BUILTIN_NAMESPACES)
  end
  
  # Construct location mappers.
  
  def location_mappers
    log(DEBUG, "parse location mapping file #{@options.location_mapping}")
    h = YAML.load_file(@options.location_mapping)
    h.inject([]) do |m, o|
      from, to = *o
      log(DEBUG, "map #{from} -> #{to}")
      m << SimpleIRIMapper.new(IRI.create(from), IRI.create(to))
    end
  end
end
