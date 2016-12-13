name 'every identified element has a label'

  query %q{
  
  <%= @namespace_defs %>

  select distinct ?ie ?audit_case_ok

  <%= @from_named_clauses_by_group['named'] %>
  <%= @from_clauses_by_group['named'] %>
  <%= @from_clauses_by_group['imported'] %>
  <%= @from_clauses_by_group_by_type['named']['ClassEntailments'] %>
  <%= @from_clauses_by_group_by_type['imported']['ClassEntailments'] %>

  where {
    
    # find all work packages defined in the named ontologies.
    
    graph ?graph { ?ie rdf:type owl:Class }
    ?ie rdfs:subClassOf base:IdentifiedElement .
    
    optional {
      ?ie rdfs:label ?name .
    }
      
    bind (bound(?name) as ?audit_case_ok)

  }
}

# Identify each test case by its IRI.

case_name { |r| r.ie.to_qname(@namespace_by_prefix) }