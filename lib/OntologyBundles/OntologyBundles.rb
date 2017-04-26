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
#    Module to support ontology bundle construction. 
#
#++

module OntologyBundles
  
  require 'set'
  require 'uri'
  require 'yaml'
  require 'JenaApplication'
  
  IRI_PREFIX = 'http://'
  ARTIFACTS_PREFIX = 'artifacts'
  IMPORTS_PREFIX = "#{ARTIFACTS_PREFIX}/imports"
  IMPORTS_SUFFIX = '/imports'
  DIGESTS_PREFIX = "#{ARTIFACTS_PREFIX}/digests"
  DIGEST_EXTENSION = '.yaml'
  CLOSURES_PREFIX = "#{ARTIFACTS_PREFIX}/bundles"
  BACKBONE_SUFFIX = '-backbone'
  EMBEDDING_SUFFIX = '-embedding'
  GROUP_SUFFIX = '-group'
  BUNDLE_SUFFIX = '-bundle'
  MAPPING_SUFFIX = '-mapping'
  METAMODEL_SUFFIX = '-metamodel'
  VIEW_SUFFIX = '-view'
  ONTOLOGIES_PREFIX = "#{ARTIFACTS_PREFIX}/ontologies"
  PRODUCTION_PREFIX = '.production'
  TESTS_PREFIX = 'tests'
  IMCE_BACKBONE_PREFIX = 'http://imce.jpl.nasa.gov/backbone'
  PREFIX_FILE = '.prefixes.yaml'
  LOCATION_MAPPING_FILE = 'location-mapping.yaml'
  
  def self.serialize(list, method = :iri)
    h = list.inject({}) do |memo, obj|
      memo[obj.send(method)] = obj
      memo
    end
    Marshal.dump(h)
  end
  
  def self.expand(list, methods, args = [])
    list.inject([]) do |memo, part|
      methods.each do |method|
        memo << part.send(method, *args)
      end
      memo
    end.reject{ |x| x.nil? }.join(' ')
  end
  
  def self.production_sentinel
    "#{PRODUCTION_PREFIX}/bundles/all"
  end
  
  def self.prefix_file
    OntologyPart.prefix_file
  end
  
  def self.namespace_map
    [ OntologyPart, OntologyBundle ].inject({}) do |m, o|
      m.merge!(o.namespace_map)
      m
    end
  end
    
  # An OntologyBundle corresponds to an OntologyGroup and its imports. Every
  # OntologyBundle is summarized by a YAML or JSON digest used for UML profile generation.
  
  class OntologyBundle
    
    @@list = Set.new
    @@clean = [ :digest_file, :artifact, :imports_artifact ]
    @@serialization_file = '.ontology-bundles-serialized'
    
    attr_reader :iri, :prefix, :file, :path, :groups, :stem, :type, :imports_iri,
      :artifact, :imports_artifact, :backbone_iri, :abbrev, :backbone_abbrev,
      :embedding_abbrev
    attr_accessor :owl2_mof2_group
    
    def initialize(path, stem, prefix = stem, digest_extension = DIGEST_EXTENSION)
      @path = path
      @stem = stem
      @prefix = prefix
      @abbrev = @prefix + BUNDLE_SUFFIX
      @embedding_abbrev = @abbrev + EMBEDDING_SUFFIX
      @backbone_abbrev = @abbrev + BACKBONE_SUFFIX
      @iri = "#{IRI_PREFIX}#{@path}/#{@stem}#{BUNDLE_SUFFIX}"
      @backbone_iri = "#{IMCE_BACKBONE_PREFIX}/#{@path}/#{@stem}#{BUNDLE_SUFFIX}"
      @imports_iri = "#{IRI_PREFIX}#{@path}/#{@stem}#{BUNDLE_SUFFIX}/#{IMPORTS_SUFFIX}"
      @artifact = "#{CLOSURES_PREFIX}/#{@path}/#{@stem}#{BUNDLE_SUFFIX}.owl"
      @imports_artifact = "#{IMPORTS_PREFIX}/#{@path}/#{@stem}#{BUNDLE_SUFFIX}.owl"
      @groups = Set.new
      @imported_bundles = Set.new
      @digest_extension = digest_extension
      @args = []
      @@list << self
    end
    
    def bundles(group)
      @groups << group
    end
    
    def imports(bundle)
      @imported_bundles << bundle
    end
    
    def imported_bundles
      @imported_bundles
    end
    
    def imported_bundles_closure
      map = Hash.new { |h, k| h[k] = Set.new }
      map.extend(Closable)
      @@list.each do |b|
        map[b] = b.imported_bundles
      end
      map.close(self)
    end
    
    def name
      @stem
    end

    def embedding_name
      name + EMBEDDING_SUFFIX
    end
    
    def self.names
      @@list.map { |b| b.name }
    end
    
    def digest_file
      "#{DIGESTS_PREFIX}/#{@path}/#{@stem}#{BUNDLE_SUFFIX}#{@digest_extension}"
    end
    
    def self.digest_files
      @@list.map { |b| b.digest_file }
    end
    
    def embedding_iri
      (@iri + EMBEDDING_SUFFIX) if type == 'imce'
    end
    
    def embedding_imports_iri
      (embedding_iri + IMPORTS_SUFFIX) if type == 'imce'
    end
    
    def embedding_artifact
      "#{CLOSURES_PREFIX}/#{@path}/#{@stem}#{BUNDLE_SUFFIX}#{EMBEDDING_SUFFIX}.owl" if @type == 'imce'
    end
    
    def self.embedding_artifacts
      @@list.map { |p| p.embedding_artifact }.reject { |v| v.nil? }
    end
    
    def embedding_imports_artifact
      "#{IMPORTS_PREFIX}/#{@path}/#{@stem}#{BUNDLE_SUFFIX}#{EMBEDDING_SUFFIX}.owl" if @type == 'imce'
    end
    
    def self.embedding_imports_artifacts
      @@list.map { |p| p.embedding_imports_artifact }.reject { |v| v.nil? }
    end
    
    def self.iris
      @@list.map { |b| b.iri }
    end
    
    def self.imports_iris
      @@list.map { |b| b.imports_iri }
    end
    
    def self.artifacts
      @@list.map { |b| b.artifact }
    end
    
    def self.imports_artifacts
      @@list.map { |b| b.imports_artifact }
    end
    
    def self.list
      @@list
    end
    
    def validation_file
      "#{TESTS_PREFIX}/#{@path}/validate-#{@stem}#{BUNDLE_SUFFIX}.xml"
    end
  
    def self.validation_files
      @@list.map { |g| g.validation_file }
    end
    
    def embedding_validation_file
      "#{TESTS_PREFIX}/#{@path}/validate-#{@stem}#{BUNDLE_SUFFIX}#{EMBEDDING_SUFFIX}.xml" if @type == 'imce'
    end
  
    def self.embedding_validation_files
      @@list.map { |g| g.embedding_validation_file }.reject { |v| v.nil? }
    end
    
    def owl_validation_file
      "#{TESTS_PREFIX}/#{@path}/validate-#{@stem}#{BUNDLE_SUFFIX}-owl.xml"
    end
  
    def self.owl_validation_files
      @@list.map { |g| g.owl_validation_file }
    end
    
    def owl_embedding_validation_file
      "#{TESTS_PREFIX}/#{@path}/validate-#{@stem}#{BUNDLE_SUFFIX}#{EMBEDDING_SUFFIX}-owl.xml" if @type == 'imce'
    end
  
    def self.owl_embedding_validation_files
      @@list.map { |g| g.owl_embedding_validation_file }.reject { |v| v.nil? }
    end
    
    def self.clean
      OntologyBundles.expand(@@list, @@clean)
    end
    
    def self.serialize
      OntologyBundles.serialize(@@list, :name)
    end
    
    def self.serialization_file=(value)
      @@serialization_file = value
    end
    
    def self.serialization_file
      @@serialization_file
    end
    
    def eql?(other)
      @group.eql?(other.group)
    end
    
    def closure_production_sentinel
      "#{PRODUCTION_PREFIX}/closures/#{@path}/#{@stem}.owl"
    end
    
    def self.closure_production_sentinels
      @@list.map { |p| p.closure_production_sentinel }.reject { |v| v.nil? }
    end
    
    def closure_embedding_production_sentinel
      "#{PRODUCTION_PREFIX}/closures/#{@path}/#{@stem}#{EMBEDDING_SUFFIX}.owl" if @type == 'imce'
    end
    
    def self.closure_embedding_production_sentinels
      @@list.map { |p| p.closure_embedding_production_sentinel }.reject { |v| v.nil? }
    end
    
    def self.location_mapping_file
      LOCATION_MAPPING_FILE
    end
    
    def self.location_mapping
      result = {}
      @@list.each do |o|
        pwd = ENV['PWD']
        result[o.iri] = "file://#{pwd}/#{o.artifact}"
        result[o.embedding_iri] = "file://#{pwd}/#{o.embedding_artifact}" if o.embedding_iri
        result[o.imports_iri] = "file://#{pwd}/#{o.imports_artifact}"
        result[o.embedding_imports_iri] = "file://#{pwd}/#{o.embedding_imports_artifact}" if o.embedding_imports_iri
      end
      result
    end
    
    def self.namespace_map
      @@list.inject({}) do |m, o|
        m[o.abbrev] = o.iri + '#'
        m[o.backbone_abbrev] = o.backbone_iri + '#'
        m
      end
    end
    
    def self.paths
      @@list.map { |p| p.path }
    end
    
    def args
      @args.join(' ')
    end
    
  end
  
  class ImceOntologyBundle < OntologyBundle
    def initialize(path, stem, prefix = stem, digest_extension = DIGEST_EXTENSION)
      super
      @type = 'imce'
    end
  end
  
  class OmgOntologyBundle < OntologyBundle
    def initialize(path, stem, prefix = stem, digest_extension = DIGEST_EXTENSION)
      super
      @type = 'omg'
    end
  end

  # An OntologyGroup corresponds to a set of OntologyParts. Embedding validation is performed at OntologyGroup level.
  
  class OntologyGroup
    
    @@list = Set.new
    @@clean = [ :validation_file ]
    @@serialization_file = '.ontology-groups-serialized'
    @@entailment_types = Set.new
     
    attr_reader :path, :parts, :stem, :iri, :embedding_iri, :predecessors
    
    def initialize(path, stem)
      @path = path
      @stem = stem
      @file = "#{path}/#{stem}.owl"
      @iri = "#{IRI_PREFIX}#{@path}/#{@stem}#{GROUP_SUFFIX}"
      @imports_iri = ""
      @parts = Set.new
      @predecessors = Set.new
      @args = []
      @@list << self
    end
    
    def <<(other)
      @parts << other
    end
    
    def add_part(stem = @stem, prefix = stem)
      @parts << op = OntologyPart.new(@path, stem, prefix)
      op
    end
    
    def non_embedding_parts
      @parts.reject { |p| p.is_embedding? }
    end
    
    def depends_on(group)
      @predecessors << group
    end
    
    def all_predecessors
      @predecessors.inject(Set.new) do |m, g|
        m << g
        m += g.all_predecessors
        m
      end
    end
    
    def owl_validation_files
      @parts.map { |p| p.owl_validation_file }
    end
  
    def self.owl_validation_files
      @@list.inject([]) { |m, g| m += g.owl_validation_files; m }
    end
    
    def validation_file
      "#{TESTS_PREFIX}/#{path}/validate-#{@stem}-group.xml"
    end
  
    def self.validation_files
      @@list.map { |g| g.validation_file }
    end
    
    def imports_artifacts
      @parts.map { |p| p.imports_artifact }
    end
    
    def self.imports_artifacts(type)
      @@list.inject([]) { |m, g| m += g.imports_artifacts(type); m }
    end
    
    def entailments_artifacts(type)
      @@entailment_types << type
      @parts.map { |p| p.entailments_artifact(type) }
    end
    
    def self.entailments_artifacts(type)
      @@entailment_types << type
      @@list.inject([]) { |m, g| m += g.entailments_artifacts(type); m }
    end
    
    def minimized_entailments_artifacts(type)
      @@entailment_types << type
      @parts.map { |p| p.minimized_entailments_artifact(type) }
    end
    
    def self.minimized_entailments_artifacts(type)
      @@entailment_types << type
      @@list.inject([]) { |m, g| m += g.minimized_entailments_artifacts(type); m }
    end
    
    def self.all_artifacts
      @@list.inject(Set.new) do |memo, group|
        memo += @@entailment_types.map { |type| group.entailments_artifact(type) } 
        memo += @@entailment_types.map { |type| group.minimized_entailments_artifact(type) } 
        memo << group.imports_artifact
      end.reject { |v| v.nil? }
    end
  
    def entailments_production_sentinels(type)
      @@entailment_types << type
      @parts.map { |p| p.entailments_production_sentinel(type) }
    end
    
    def self.entailments_production_sentinels(type)
      @@entailment_types << type
      @@list.inject([]) { |m, g| m += g.entailments_production_sentinels(type); m }
    end
    
    def all_sentinels
      @@list.inject(Set.new) do |memo, group|
        @@entailment_types.map do |type|
          memo += group.entailments_production_sentinels(type)
        end
      memo
      end.reject { |v| v.nil? }
    end
    
    def self.clean
      OntologyBundles.expand(@@list, @@clean)
    end
    
    def self.list
      @@list
    end
    
    def self.serialize
      OntologyBundles.serialize(@@list)
    end
    
    def self.serialization_file=(value)
      @@serialization_file = value
    end
    
    def self.serialization_file
      @@serialization_file
    end
    
    def eql?(other)
      @path.eql?(other.path) && @stem.eql?(other.stem)
    end
    
    def args
      @args.join(' ')
    end
    
  end
  
  class ImceOntologyGroup < OntologyGroup
    def initialize(path, stem)
      super
      @args << '--type imce'
    end
    def do_embedding?
      true
    end
    def full_reification?
      true
    end
  end
  
  class ImceOwl2Mof2OntologyGroup < ImceOntologyGroup
    def do_embedding?
      false
    end
    def full_reification?
      true
    end
  end
  
  class OmgOntologyGroup < OntologyGroup
    def initialize(path, stem)
      super
      @args << '--type omg'
    end
    def do_embedding?
      false
    end
    def full_reification?
      true
    end
  end

  # An OntologyPart is an OWL file with IRI and optional namespace prefix. XML
  # and OWL validation are performed at OntologyPart level.
  
  class OntologyPart
    
    @@list = Set.new
    @@clean = [:ontology_artifact, :owl_validation_file, :imports_artifact, :ontology_production_sentinel]
    @@serialization_file = '.ontology-parts-serialized'
    @@prefix_file = PREFIX_FILE
      
    attr_reader :prefix, :stem, :sep, :iri, :file, :ontology_artifact,
      :ontology_production_sentinel, :path, :owl_validation_file, :serialization_file, :backbone_prefix,
      :backbone_iri
      
    def initialize(path, stem, prefix = stem, sep = '#')
      @embedding = false
      @path = path
      @stem = stem
      @prefix = prefix
      @backbone_prefix = prefix + BACKBONE_SUFFIX
      @sep = sep
      @iri = "#{IRI_PREFIX}#{@path}/#{@stem}"
      @backbone_iri = "#{IMCE_BACKBONE_PREFIX}/#{@path}/#{@stem}"
      @file = "#{path}/#{stem}.owl"
      @serialization_file = ""
      @ontology_artifact = "#{ONTOLOGIES_PREFIX}/#{@file}"
      @ontology_artifact_only = false
      @@list << self
    end
    
    def ontology_artifact_only=(value)
      @ontology_artifact_only = value
    end
    
    def ontology_artifact_only?
      @ontology_artifact_only
    end
    
    def inhibit(value)
      @ontology_artifact_only ? nil : value
    end
    
    def self.iris
      @@list.reject { |p| p.ontology_artifact_only? }.map { |v| v.iri }
    end
    
    def self.files
      @@list.map { |p| p.file }
    end
    
    def owl_validation_file
      inhibit("#{TESTS_PREFIX}/#{path}/validate-#{@stem}-owl.xml")
    end
  
    def self.owl_validation_files
      @@list.map { |p| p.owl_validation_file }.reject { |v| v.nil? }
    end
    
    def self.ontology_artifacts
      @@list.map { |p| p.ontology_artifact }
    end
    
    def ontology_production_sentinel
      inhibit("#{PRODUCTION_PREFIX}/#{@file}")
    end
    
    def self.ontology_production_sentinels
      @@list.map { |p| p.ontology_production_sentinel }.reject { |v| v.nil? }
    end

    def imports_iri
      inhibit("#{IRI_PREFIX}#{@path}/#{@stem}#{IMPORTS_SUFFIX}")
    end
    
    def self.imports_iris
      @@list.map { |p| p.imports_iri }.reject { |v| v.nil? }
    end
  
    def imports_artifact
      inhibit("#{IMPORTS_PREFIX}/#{@file}")
    end
    
    def self.imports_artifacts
      @@list.map { |p| p.imports_artifact }.reject { |v| v.nil? }
    end
    
    def entailments_production_sentinel(type)
      inhibit("#{PRODUCTION_PREFIX}/entailments/#{@path}/#{@stem}/#{type}.owl")
    end
    
    def entailments_iri(type)
      inhibit("#{@iri}/#{type}")
    end
    
    def entailments_artifact(type)
      inhibit("#{ARTIFACTS_PREFIX}/entailments/#{@path}/#{@stem}/#{type}.owl")
    end
    
    def self.entailments_artifacts(type)
      @@list.map { |p| p.entailments_artifact(type) }.reject { |v| v.nil? }
    end
    
    def minimized_entailments_artifact(type)
      inhibit("#{ARTIFACTS_PREFIX}/minimized-entailments/#{@path}/#{@stem}/#{type}.owl")
    end
    
    def self.minimized_entailments_artifacts(type)
      @@list.map { |p| p.minimized_entailments_artifact(type) }.reject { |v| v.nil? }
    end
    
    def self.paths
      @@list.map { |p| p.path }
    end
    
    def self.each(&block)
      @@list.each(&block)
    end
    
    def self.list
      @@list
    end
    
    def self.clear_list
      @@list = Set.new
    end
    
    def self.clean
      OntologyBundles.expand(@@list, @@clean)
    end
    
    def self.serialize
      OntologyBundles.serialize(@@list)
    end
    
    def self.serialization_file=(value)
      @@serialization_file = value
    end
    
    def self.serialization_file
      @@serialization_file
    end
    
    def self.namespace_map
      @@list.inject({}) do |m, o|
        m[o.prefix] = o.iri + o.sep
        m[o.backbone_prefix] = o.backbone_iri + '#'
        m
      end
    end
    
    def self.prefix_file=(value)
      @@prefix_file = value
    end
    
    def self.prefix_file
      @@prefix_file
    end
    
    def eql?(other)
      @path.eql?(other.path) && @stem.eql?(other.stem) && @prefix.eql?(other.prefix)
    end
    
    def self.location_mapping_file
      LOCATION_MAPPING_FILE
    end
    
    def self.location_mapping
      result = {}
      @@list.each do |o|
        pwd = ENV['PWD']
        result[o.iri] = "file://#{pwd}/#{o.file}"
        result[o.imports_iri] = "file://#{pwd}/#{o.imports_artifact}" if o.imports_iri 
      end
      result
    end
    
    def is_embedding?
      !!@is_embedding
    end
    
    def is_metamodel?
      !!@is_metamodel
    end
    
    def is_view?
      !!@is_view
    end
    
    def is_normal?
      !is_embedding? && !is_metamodel? && !is_view?
    end
    
  end
  
  class OntologyEmbeddingPart < OntologyPart
    
    def initialize(path, stem, prefix = stem, sep = '#')
      super
      @is_embedding = true
    end
    
  end
  
  class OntologyViewPart < OntologyPart
    
    def initialize(path, stem, prefix = stem, sep = '#')
      super
      @is_view = true
    end
    
  end
  
  class OntologyMetamodelPart < OntologyPart
    
    def initialize(path, stem, prefix = stem, sep = '#')
      super
      @is_metamodel = true
    end
    
  end
  
end
