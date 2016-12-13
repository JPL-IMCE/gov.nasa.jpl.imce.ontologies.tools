name 'every entity specializes an IMCE entity'

prologue {
  @backbone_entities = @ontologies_by_group['named'].map do |o|
    b = o.sub(/\Ahttp:\/\//, 'http://imce.jpl.nasa.gov/backbone/')
    e = b + '#Entity'
    u = e.to_uriref
  end
}

  query %q{
  
  <%= @namespace_defs %>

  select distinct ?entity ?audit_case_ok

  <%= @from_named_clauses_by_group['named'] %>
  <%= @from_clauses_by_group['named'] %>
  <%= @from_clauses_by_group['imported'] %>
  <%= @from_clauses_by_group_by_type['named']['ClassEntailments'] %>
  <%= @from_clauses_by_group_by_type['imported']['ClassEntailments'] %>

  where {
    
    # find all classes defined in the named ontologies.
    
    graph ?graph { ?entity rdf:type owl:Class }
      
    # select only backbone entities
      
    ?entity rdfs:subClassOf ?backbone_entity .
      
    bind (exists { ?entity rdfs:subClassOf project-bundle-backbone:Entity } as ?audit_case_ok)    
      
    filter (
         <%= @backbone_entities.equal_any?('?backbone_entity') %>
      && ! <%= @backbone_entities.equal_any?('?entity') %>
    )
  }
}

case_name { |r| r.entity.to_qname(@namespace_by_prefix) }