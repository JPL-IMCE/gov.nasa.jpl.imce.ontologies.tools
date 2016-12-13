name 'every city is a capital 5'

query %q{
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>  
  SELECT DISTINCT ?cty WHERE { ?cty rdf:type <http://www.mooney.net/geo#City>. }
}

prologue { @save = [] }
  
filter { |r, emit| emit.call(r) if r }
  
filter do |r, emit|
  if r
    @save.unshift(r)
  else
    @save.each { |s| emit.call(s) }
  end
end
  
query %q{
  PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>  
  SELECT DISTINCT ?audit_case_name ?audit_case_ok
  WHERE {
    BIND(?cty AS ?audit_case_name)
    BIND(EXISTS {?cty rdf:type <http://www.mooney.net/geo#Capital>} AS ?audit_case_ok)
  }
}