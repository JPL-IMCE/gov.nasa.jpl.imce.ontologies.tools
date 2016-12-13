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
#    Adaptation of Application library for use with Sesame. 
#
#++

require 'Application'

class SesameApplication < Application
  
  require 'tsort'
  require 'yaml'
  require 'jpl/rdf/sesame'
  
  # Define constants.
  
  ANNOTATION_IRI = 'http://imce.jpl.nasa.gov/foundation/annotation/annotation'
  
  EMBEDDING_STRING = '-embedding'
  
  WWW_OMG_ORG = 'http://imce.jpl.nasa.gov/www.omg.org'
  WWW_OMG_ORG_ES = Regexp.escape(WWW_OMG_ORG)
  WWW_OMG_ORG_RE = Regexp.new(WWW_OMG_ORG_ES)
  WWW_OMG_ORG_SPARQL_RE = WWW_OMG_ORG_ES.gsub(/\\/, '\\\\\\')
  
  WWW_W3_ORG = 'http://www.w3.org'
  WWW_W3_ORG_ES = Regexp.escape(WWW_W3_ORG)
  WWW_W3_ORG_RE = Regexp.new(WWW_W3_ORG_ES)
  WWW_W3_ORG_SPARQL_RE = WWW_W3_ORG_ES.gsub(/\\/, '\\\\\\')
  
  IMCE_JPL_NASA_GOV = 'http://imce.jpl.nasa.gov'
  IMCE_JPL_NASA_GOV_ES = Regexp.escape(IMCE_JPL_NASA_GOV)
  IMCE_JPL_NASA_GOV_RE = Regexp.new(IMCE_JPL_NASA_GOV_ES)
  IMCE_JPL_NASA_GOV_SPARQL_RE = IMCE_JPL_NASA_GOV_ES.gsub(/\\/, '\\\\\\')
  
  PURL_ORG = 'http://purl.org/dc/elements'
  PURL_ORG_ES = Regexp.escape(PURL_ORG)
  PURL_ORG_RE = Regexp.new(PURL_ORG_ES)
  PURL_ORG_SPARQL_RE = PURL_ORG_ES.gsub(/\\/, '\\\\\\')
  
  DEFAULT_HOST = 'localhost'
  DEFAULT_PORT = '8080'
  DEFAULT_PATH = 'openrdf-sesame'
  DEFAULT_REPO = nil
  DEFAULT_IMPORTS_FILE = nil
  DEFAULT_ENTAILMENT_TYPES = 'ClassEntailments,PropertyEntailments'

  #  Helper module for topological sorting.
  
  module TSortMethods
    include TSort
    def tsort_each_node(&block)
      each_key(&block)
    end
    def tsort_each_child(node, &block)
      begin
        self.fetch(node).each(&block)
      rescue IndexError
      end
    end
  end

  def run
    
    add_options
    
    super
    
    unless @options.repo
      log(FATAL, 'no Sesame repo specified')
      return 1
    end
    unless @session = start_session
      log(FATAL, 'no Sesame session')
      return 1
    end
    unless @model = create_model
      log(FATAL, 'no Sesame model')
      return 1
    end
    @namespace_by_prefix = get_namespaces
    RDF::Uri.ns_by_prf = @namespace_by_prefix
    @nsm = create_namespace_map
    @namespace_defs = create_namespace_defs
    if @imports_by_ontology = load_imports
      @named_ontologies, @imported_ontologies, @sorted_ontologies = *collect_ontologies(argv)
      @ontologies_by_group = partition_by_group
      @ontologies_by_group_by_type = construct_entailment_uris(@options.entailment_types)
      @from_clauses_by_group, @from_clauses_by_group_by_type = *construct_from_clauses
      @from_named_clauses_by_group, @from_named_clauses_by_group_by_type = *construct_from_clauses(true)
    end
    
  end
  
  private
  
  # Add options for connection to Sesame.
  
  def add_options
  
    @options.host = DEFAULT_HOST
    option_parser.on('--host HOST', "Sesame host (#{DEFAULT_HOST})") do |v|
      @options.host = v
    end
    @options.port = DEFAULT_PORT 
    option_parser.on('--port HOST', "Sesame port (#{DEFAULT_PORT})") do |v|
      @options.port = v
    end
    @options.path = DEFAULT_PATH
    option_parser.on('--path PATH', "Sesame path (#{DEFAULT_PATH})") do |v|
      @options.path = v
    end
    @options.repo = DEFAULT_REPO
    option_parser.on('--repo REPO', "Sesame repo (#{DEFAULT_REPO})") do |v|
      @options.repo = v
    end
    @options.imports_file = DEFAULT_IMPORTS_FILE
    option_parser.on('--imports-file FILE', "ontology imports file (#{DEFAULT_IMPORTS_FILE})") do |v|
      @options.imports_file = v
    end
    @options.entailment_types = DEFAULT_ENTAILMENT_TYPES
    option_parser.on('--entailment-types LIST', "entailment types (#{DEFAULT_ENTAILMENT_TYPES})") do |v|
      @options.imports_file = v
    end
  
  end
  
  # Connect to Sesame server.

  def start_session(host = @options.host, port = @options.port, path = @options.path)
    
    log(INFO, "begin Sesame session (#{@options.host}, #{@options.port}, #{@options.path})")
    RDF::Sesame::Session.new(@options.host, @options.port, @options.path, @log)
    
  end
  
  # Create Sesame model.

  def create_model(repo = @options.repo)
    
    log(INFO, "create model #{@options.repo}")
    @session.model(@options.repo)
    
  end
  
  # Get namespace definitions.

  def get_namespaces(model = @model)

    log(INFO, 'get namespace definitions')
    namespace_by_prefix = {}
    model.namespaces.map do |defn|
      prf = defn.prefix.to_s
      ns = defn.namespace.to_s
      namespace_by_prefix[prf] = ns
    end
    log(DEBUG, "namespace_by_prefix: #{@namespace_by_prefix.inspect}")
    namespace_by_prefix
    
  end
  
  def create_namespace_map(namespace_by_prefix = @namespace_by_prefix)
    
    nsm = {}
    namespace_by_prefix.each do |prf, ns|
      nsm[prf] = RDF::NamespaceMap.new(ns)
    end
    nsm
      
  end
  
  # Construct SPARQL prefixes.

  def create_namespace_defs(nsm = @nsm)
    
    log(INFO, 'construct sparql prefixes')
    namespace_defs = nsm.map do |prf, ns|
      "PREFIX #{prf}:#{nsm[prf][''].to_uriref}"
    end.join("\n")
    log(DEBUG, "namespace_defs: #{namespace_defs}")
    namespace_defs
    
  end
  
  # Load imports graph.

  def load_imports(imports_file = @options.imports_file)

    log(INFO, "load imports graph #{imports_file}")
    imports_by_ontology = case imports_file
    when nil
      nil
    else
      YAML.load(File.open(imports_file))['closure']
    end
    log(DEBUG, "imports_by_ontology: #{imports_by_ontology.inspect}")
    imports_by_ontology
    
  end

  # Collect ontology URIs.

  def collect_ontologies(named_uris, imports_by_ontology = @imports_by_ontology)
    
    log(INFO, 'collect ontology uris')
    named_ontologies = Set.new(named_uris.map { |u| RDF::Uri.new(u) })
    imported_ontologies = named_uris.inject(Set.new) do |m, u|
      m += imports_by_ontology[u].map { |i| RDF::Uri.new(i)  }
      m
    end
    imported_ontologies -= named_ontologies
    ontologies = named_ontologies + imported_ontologies
    log(DEBUG, "named_ontologies: #{named_ontologies.inspect}")
    log(DEBUG, "imported_ontologies: #{imported_ontologies.inspect}")
    
    imports_by_ontology.extend(TSortMethods)
    sorted_ontologies = imports_by_ontology.tsort.reverse
    log(DEBUG, "sorted_ontologies: #{sorted_ontologies.inspect}")
    
    [named_ontologies, imported_ontologies, sorted_ontologies]

  end
   
  # Partition ontologies by group: imce/omg and named/imported.

  def partition_by_group(named_ontologies = @named_ontologies, imported_ontologies = @imported_ontologies)
    
    log(INFO, 'partition ontologies by group')
    ontologies_by_group = {}
    ontologies = named_ontologies + imported_ontologies
    { 'imce' => IMCE_JPL_NASA_GOV_RE, 'omg' => WWW_OMG_ORG_RE }.each do |group, re|
      ontologies_by_group[group] = ontologies.select { |o| o.to_s =~ re }
    end
    { 'named' => named_ontologies, 'imported' => imported_ontologies,
      'annotation' => [RDF::Uri.new(ANNOTATION_IRI)] }.each do |group, olist|
      ontologies_by_group[group] = olist
    end
    ontologies_by_group.keys.each do |group|
      g = group + "-no#{EMBEDDING_STRING}"
      ontologies_by_group[g] = ontologies_by_group[group].reject { |o| o.to_s =~ /#{EMBEDDING_STRING}\z/ }
    end
    ontologies_by_group.each do |group, olist|
      log(DEBUG, "ontologies_by_group['#{group}'] = #{olist.inspect}")
    end
    ontologies_by_group
    
  end
  
  # Construct ontology URIs for entailments.

  def construct_entailment_uris(types, ontologies_by_group = @ontologies_by_group)
    
    log(INFO, 'construct entailment uris')
    entailment_types = types.split(/\s*,\s*/)
    ontologies_by_group_by_type = Hash.new { |h, k| h[k] = Hash.new { |l, m| l[m] = [] } }
    ontologies_by_group.each do |group, olist|
      entailment_types.each do |etype|
        ontologies_by_group_by_type[group][etype] = olist.map { |o| RDF::Uri.new(o + "/#{etype}") }
        log(DEBUG, "ontologies_by_group_by_type['#{group}']['#{etype}'] = #{ontologies_by_group_by_type[group][etype].inspect}")
      end
    end
    ontologies_by_group_by_type
    
  end
  
  # Construct SPARQL 'from' and 'from named' clauses.

  def construct_from_clauses(named = false, ontologies_by_group = @ontologies_by_group,
    ontologies_by_group_by_type = @ontologies_by_group_by_type)

    if named
      n1 = 'named '
      n2 = 'named_'
    else
      n1 = n2 = ''
    end
    log(INFO, "construct 'from' clauses")
    from_clauses_by_group = {}
    ontologies_by_group.each do |group, list|
      from_clauses_by_group[group] = list.map { |ont| "from #{n1}#{ont.to_uriref}" }.join("\n")
      log(DEBUG, "from_#{n2}clauses_by_group['#{group}'] = #{from_clauses_by_group[group].inspect}")
    end

    from_clauses_by_group_by_type = Hash.new { |h, k| h[k] = Hash.new { |l, m| l[m] = [] } }
    ontologies_by_group_by_type.each do |group, hash|
      hash.each do |etype, list|
        from_clauses_by_group_by_type[group][etype] = list.map { |ont| "from #{n1}#{ont.to_uriref}" }.join("\n")
        log(DEBUG, "from_#{n2}clauses_by_group_by_type['#{group}']['#{etype}'] = #{from_clauses_by_group_by_type[group][etype].inspect}")
      end
    end
    [from_clauses_by_group, from_clauses_by_group_by_type]
    
  end

end

# Define utility functions.

module Enumerable
  
  def equal_any(var)
    '(' + map { |val| "#{var} = #{val.to_uriref}" }.push('false').join(' || ') + ')'
  end
  
end
