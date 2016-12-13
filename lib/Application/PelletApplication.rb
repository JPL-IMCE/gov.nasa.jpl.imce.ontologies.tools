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
#    Adaptation of Application library for use with Pellet.
#
#    Note: should specialize JenaApplication, but Pellet 2.3.1 and earlier
#          are incompatible with Jena 2.10.1 and later.
#
#++

require 'Application'

class PelletApplication < Application
  
  require 'pellet'
  require 'yaml'
  
  DEFAULT_LOCATION_MAPPING = 'location-mapping.yaml'
  
  def run
    
    add_options
    
    super
      
  end
  
  private
  
  def add_options
  
    @options.location_mapping = DEFAULT_LOCATION_MAPPING
    option_parser.on('--location-mapping FILE', 'location mapping file') do |v|
      @options.location_mapping = v
    end

  end
  
  # Construct location mappers.
  
  def location_mappers
    log(DEBUG, "parse location mapping file #{@options.location_mapping}")
    h = YAML.load_file(@options.location_mapping)
    h.inject([]) do |m, o|
      from, to = *o
      unless from && to
        log(FATAL, "nil value in mapping #{from.inspect} -> #{to.inspect}")
        raise
      end
      log(DEBUG, "map #{from} -> #{to}")
      m << SimpleIRIMapper.new(IRI.create(from), IRI.create(to))
    end
  end

end