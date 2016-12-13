name 'demo-03 a borders b implies b borders a'

query %q{
  <%= @namespace_defs %>
  PREFIX : <http://www.mooney.net/geo#>
  SELECT DISTINCT ?state_1 ?state_2 ?audit_case_ok
  <%= @from_clauses_by_group['named'] %>
  WHERE {
    ?state_1_uri :borders ?state_2_uri.
    ?state_1_uri rdfs:label ?state_1.
    ?state_2_uri rdfs:label ?state_2.
    BIND(EXISTS {?state_2_uri :borders ?state_1_uri} AS ?audit_case_ok)
  }
  ORDER BY ?state_1 ?state_2
}

case_name { |r| "#{r.state_1} borders #{r.state_2}" }