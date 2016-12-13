name 'every city is a capital 2'

query %q{
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>  
  SELECT DISTINCT ?cty ?capital
  WHERE {
    ?cty rdf:type <http://www.mooney.net/geo#City>.
    BIND(EXISTS {?cty rdf:type <http://www.mooney.net/geo#Capital>} AS ?capital)
  }
}

predicate { |r| r.capital.true? ? [true, nil] : [false, 'not a capital.' ] }
case_name { |r| "city: #{r.cty}" }