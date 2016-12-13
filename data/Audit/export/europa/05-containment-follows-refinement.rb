name 'containment follows refinement'

  query %q{
  
  <%= @namespace_defs %>

  select distinct ?r_sup ?r_inf ?audit_case_ok

  from <http://imce.jpl.nasa.gov/view/named>
  
  where {
    
    # Find requirements ?r_inf and ?r_sup in a refinement relationship, and the things they specify.
    # Pellet does not include owl:Restrictions in its subclass entailments, so we have to check if the
    # inferior requirement is a subclass of something (possibly itself) that inherits the Restriction on
    # mission:refines.
    
    ?r_inf rdfs:subClassOf mission:Requirement ;
           rdfs:subClassOf [
                             rdfs:subClassOf [             
                                               owl:onProperty mission:refines ;
                                               owl:someValuesFrom ?r_sup
                                             ]
                           ] .
                           
    # Find the element specified by each requirement.
                                                      
    ?r_inf mission:specifies ?se_inf .
    ?r_sup mission:specifies ?se_sup .
           
    # Check if the superior element (directly) contains the inferior. Needs transitive closure but that
    # cannot be expressed with property paths for Restrictions.
    
    bind (
      exists {
        ?se_sup rdfs:subClassOf [
                                  rdfs:subClassOf [
                                                    owl:onProperty base:contains ;
                                                    owl:someValuesFrom ?se_inf
                                                  ]
                                ] . 
      }
      as ?audit_case_ok)

  }
}

# Identify each test case by its IRI.

case_name { |r| "#{r.r_inf} refines #{r.r_sup}" }