name 'demo-06 the states a river runs through are connected'

prologue do
  require 'set'
  require 'union_find'

  @states_by_river = Hash.new { |h, k| h[k] = Set.new }
  @borders_by_state = Hash.new { |h, k| h[k] = Set.new }
end

query %q{
  <%= @namespace_defs %>
  PREFIX : <http://www.mooney.net/geo#>
  SELECT DISTINCT ?river ?state
  <%= @from_clauses_by_group['named'] %>
  WHERE {
    ?river_uri :runsThrough ?state.
    ?river_uri rdfs:label ?river.
  }
  ORDER BY ?river
}

filter do |r, emit|
  if r
    @states_by_river[r.river] << r.state
  else
    emit.call(QuerySolutionMap.new)   # trigger downstream query
  end
end

query %q{
  <%= @namespace_defs %>
  PREFIX : <http://www.mooney.net/geo#>
  SELECT DISTINCT ?state_1 ?state_2
  <%= @from_clauses_by_group['named'] %>
  WHERE {
    ?state_1 :borders ?state_2.
  }
}

filter do |r, emit|
  if r
    @borders_by_state[r.state_1] << r.state_2
  else
    @states_by_river.each do |river, states|
      uf = UnionFind::UnionFind.new(states)
      states.each do |state|
        @borders_by_state[state].each do |border|
          uf.union(state, border) if states.include?(border)
        end
      end
      result = QuerySolutionMap.new
      result.river = river
      regions = ModelFactory.createDefaultModel.createTypedLiteral(uf.count_isolated_components, XSDDatatype::XSDinteger)
      result.regions = regions
      emit.call(result)
    end
  end
end

case_name { |r| r.river }
  
predicate do |r|
  if (regions = r.regions.getInt) == 1
    [true, nil]
  else
    [false, "#{regions} isolated regions"]
  end
end
