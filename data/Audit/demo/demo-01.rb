name 'demo-01 every city is a capital'

query %q{
  <%= @namespace_defs %>
  PREFIX : <http://www.mooney.net/geo#>
  SELECT DISTINCT ?audit_case_name ?audit_case_ok
  <%= @from_clauses_by_group['named'] %>
  WHERE {
    ?city rdf:type :City.
    ?city rdfs:label ?audit_case_name.
    BIND(EXISTS {?city rdf:type :Capital} AS ?audit_case_ok)
  }
}