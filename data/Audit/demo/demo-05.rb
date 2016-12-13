name 'demo-05 every state borders at least two other states'

query %q{
  <%= @namespace_defs %>
  PREFIX : <http://www.mooney.net/geo#>
  SELECT DISTINCT ?audit_case_name ?at_least_1 ?at_least_2
  <%= @from_clauses_by_group['named'] %>
  WHERE {
    ?state rdf:type :State.
    ?state rdfs:label ?audit_case_name.
    OPTIONAL {
      ?state :borders ?borders_1.
      OPTIONAL {
        ?state :borders ?borders_2.
        filter (?borders_1 != ?borders_2)
      }
    }
    BIND(BOUND(?borders_1) as ?at_least_1)
    BIND(BOUND(?borders_2) as ?at_least_2)
  }
}

predicate do |r|
  if r.at_least_2.true?
    [true, nil]
  elsif r.at_least_1.true?
    [false, 'Borders one.']
  else
    [false, 'Borders zero.']
  end
end