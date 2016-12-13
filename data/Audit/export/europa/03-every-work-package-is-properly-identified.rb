name 'every work package is properly identified'

  query %q{
  
  <%= @namespace_defs %>

  select distinct ?wp ?name_bound ?name ?audit_case_ok

  <%= @from_named_clauses_by_group['named'] %>
  <%= @from_clauses_by_group['named'] %>
  <%= @from_clauses_by_group['imported'] %>
  <%= @from_clauses_by_group_by_type['named']['ClassEntailments'] %>
  <%= @from_clauses_by_group_by_type['imported']['ClassEntailments'] %>

  where {
    
    # find all work packages defined in the named ontologies.
    
    graph ?graph { ?wp rdf:type owl:Class }
    ?wp rdfs:subClassOf project:WorkPackage .
    
    optional {
      ?wp rdfs:label ?name .
    }
      
    bind (bound(?name) as ?name_bound)
    
    # Determine whether the WP name begins with a sequence of dot-separated digit strings of length 1 or 2
    # followed by a single space and an upper case letter. (The extra backslashes are necessary because this
    # query fragment is processed by a templating system.)
        
    bind (?name_bound && regex(?name, "^\\\\d{1,2}(\\\\.(\\\\d{1,2})+)* \\\\p{Lu}") as ?audit_case_ok)    
      
    # Note: we could also check this assertion using Ruby regular expressions in the predicate below.
  }
}

# Identify each test case by its IRI.

case_name { |r| r.wp.to_qname(@namespace_by_prefix) }
  
# Include the work package name in the failure text.

predicate do |r|
  if r.audit_case_ok.true?
    [true, nil]
  elsif r.name_bound.true?
    [false, "invalid prefix #{r.name.getLexicalForm}"]
  else
    [false, 'no name restriction']
  end
end