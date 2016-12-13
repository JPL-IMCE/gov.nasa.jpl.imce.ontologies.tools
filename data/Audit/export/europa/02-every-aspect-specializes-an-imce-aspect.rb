name 'every aspect specializes an IMCE aspect'

prologue {
  @backbone_aspects = @ontologies_by_group['named'].map do |o|
    b = o.sub(/\Ahttp:\/\//, 'http://imce.jpl.nasa.gov/backbone/')
    e = b + '#Aspect'
    u = e.to_uriref
  end
}

  query %q{
  
  <%= @namespace_defs %>

  select distinct ?aspect ?audit_case_ok

  <%= @from_named_clauses_by_group['named'] %>
  <%= @from_clauses_by_group['named'] %>
  <%= @from_clauses_by_group['imported'] %>
  <%= @from_clauses_by_group_by_type['named']['ClassEntailments'] %>
  <%= @from_clauses_by_group_by_type['imported']['ClassEntailments'] %>

  where {
    
    # find all classes defined in the named ontologies.
    
    graph ?graph { ?aspect rdf:type owl:Class }
      
    # select only backbone aspects
      
    ?aspect rdfs:subClassOf ?backbone_aspect .
      
    bind (exists { ?aspect rdfs:subClassOf project-bundle-backbone:Aspect } as ?audit_case_ok)    
      
    filter (
         <%= @backbone_aspects.equal_any?('?backbone_aspect') %>
      && ! <%= @backbone_aspects.equal_any?('?aspect') %>
    )
  }
}

case_name { |r| r.aspect.to_qname(@namespace_by_prefix) }