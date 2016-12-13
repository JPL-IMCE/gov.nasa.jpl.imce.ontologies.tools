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
#    Unit tests for OntologyBundles module. Not up to date.
#
#++

require 'test/unit'
require 'OntologyBundles'

include OntologyBundles

class OntologyPartTests < Test::Unit::TestCase
  
  def setup
    
    OntologyPart.clear_list
    
  end
  
  def test_initialize
    
    path = 'ontology_part_path'
    stem = 'stem'
    prefix = 'prefix'
    
    iri = "#{IRI_PREFIX}/#{path}/#{stem}"
    file = "#{path}/#{stem}.owl"
    ontology_artifact = "#{ONTOLOGIES_PREFIX}/#{path}/#{stem}.owl"
    imports_artifact = "#{IMPORTS_PREFIX}/#{path}/#{stem}.owl"
    production_sentinel = "#{PRODUCTION_PREFIX}/#{path}/#{stem}.owl"
    
    op1 = OntologyPart.new(path, stem, prefix)
    assert_equal(prefix, op1.prefix, 'set prefix')
    assert_equal(iri, op1.iri, 'set iri')
    assert_equal(file, op1.file, 'set file')
    assert_equal(ontology_artifact, op1.ontology_artifact, 'set ontology artifact')
    assert_equal(imports_artifact, op1.imports_artifact, 'set imports artifact')
    assert_equal(production_sentinel, op1.production_sentinel, 'set production sentinel')
    
    op2 = OntologyPart.new(path, stem)
    assert_nil(op2.prefix, 'set prefix')
    assert_equal(iri, op2.iri, 'set iri')
    assert_equal(file, op2.file, 'set file')
    assert_equal(ontology_artifact, op2.ontology_artifact, 'set ontology artifact')
    assert_equal(imports_artifact, op2.imports_artifact, 'set imports artifact')
    
    assert_equal([op1, op2], OntologyPart.list, 'ontology parts list')
    
    ol = []
    OntologyPart.each { |p| ol << p }
    assert_equal([op1, op2], ol, 'ontology parts iterator')
  
    assert_equal(4 * 2, OntologyPart.clean.length, 'ontology parts clean length')
    
  end
  
end

class OntologyGroupTests < Test::Unit::TestCase
  
  def test_initialize
    
    path = 'ontology/path'
    normal_stem = 'normal_stem'
    normal_prefix = 'normal_prefix'
    embedding_stem = 'embedding_stem'
    embedding_prefix = 'embedding_prefix'
    n_parts = 5
    
    og = OntologyGroup.new(path)
    assert_equal(path, og.path, 'set path')
    assert(og.normal_parts.empty?, 'normal parts empty')
    assert(og.embedding_parts.empty?, 'embedding parts empty')
    
    1.upto(n_parts) do |n|
      ns = "#{normal_stem}_{n}"
      np = "#{normal_prefix}_{n}"
      npt = og.add_normal_part(ns, np)
      assert_instance_of(OntologyPart, npt, 'normal part type')
      assert_equal("#{IRI_PREFIX}/#{path}/#{ns}", npt.iri, 'normal part iri')
      assert_equal(n, og.normal_parts.length, 'normal parts length')
    end
    
    1.upto(n_parts) do |n|
      es = "#{embedding_stem}_{n}"
      ep = "#{embedding_prefix}_{n}"
      ept = og.add_embedding_part(es, ep)
      assert_instance_of(OntologyPart, ept, 'embedding part type')
      assert_equal("#{IRI_PREFIX}/#{path}/#{es}", ept.iri, 'embedding part iri')
      assert_equal(n, og.embedding_parts.length, 'embedding parts length')
    end
    
  end

end
  
class OntologyBundleTests < Test::Unit::TestCase
    
  def test_initialize
    assert true
  end
  
end