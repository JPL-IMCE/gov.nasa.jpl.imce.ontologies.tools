name '01 entity by IMCE class'

query %q{
  
  <%= @namespace_defs %>

  select distinct ?entity ?super_class ?type

  from named <http://imce.jpl.nasa.gov/view/named>
  from named <http://imce.jpl.nasa.gov/view/imported>

  where {
    
    # 20983 user without Thing, Nothing filter
#    graph <http://imce.jpl.nasa.gov/view/named> { ?entity rdf:type owl:Class }
#    graph <http://imce.jpl.nasa.gov/view/imported> { ?super_class rdf:type owl:Class }
#    ?entity rdfs:subClassOf ?super_class .
    
    graph <http://imce.jpl.nasa.gov/view/imported> {
      ?super_class rdf:type owl:Class .
    }
    graph <http://imce.jpl.nasa.gov/view/named> {
      ?entity rdfs:subClassOf ?super_class .
    }
    
    bind(if(exists {
        graph <http://imce.jpl.nasa.gov/view/imported> {
          ?super_class annotation:isAbstract true
        }
      }, "abstract", "concrete") as ?type)

    filter (
         !isBlank(?super_class)
      && ?super_class != owl:Thing
      && ?super_class != owl:Nothing
      && ?entity != owl:Thing
      && ?entity != owl:Nothing
    )
  }
}