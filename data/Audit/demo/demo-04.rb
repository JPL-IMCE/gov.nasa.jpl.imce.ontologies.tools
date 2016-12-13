name 'demo-04 every state borders at least two other states'

query %q{
  <%= @namespace_defs %>
  PREFIX : <http://www.mooney.net/geo#>
  SELECT DISTINCT ?audit_case_name ?audit_case_ok
  <%= @from_clauses_by_group['named'] %>
  WHERE {
    ?state rdf:type :State.
    ?state rdfs:label ?audit_case_name
    OPTIONAL {
      ?state :borders ?borders_1.
      ?state :borders ?borders_2.
      filter (?borders_1 != ?borders_2)
    }
    BIND(BOUND(?borders_1) as ?audit_case_ok)
  }
}
