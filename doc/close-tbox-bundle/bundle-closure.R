library(igraph)

plot_tree <- function(tree, layout=layout_as_tree) {
  plot(tree, layout=layout, vertex.shape = "none", vertex.label.family="sans",
       edge.arrow.mode=0, edge.width=2)
}

disjoint_classes_axioms <- function(l) {
  lapply(l, FUN=function(x) paste("DisjointClasses( ", paste(x, collapse=" "), " )", sep=""))
}

children <- function(tree, vertex) {
  names(neighbors(tree, vertex, "out"))
}

map_from_tree <- function(tree) {
  parents <- V(tree)[degree(tree, mode="out") > 1]
  lapply(parents, FUN=function(v) children(tree, v))
}

diam_edges <- c("a", "b", "a", "c", "b", "d", "c", "d")
diam_tree <- make_directed_graph(diam_edges)
diam_layout <- layout_as_tree(diam_tree)
diam_layout[4,1] <- 0

buc <-paste("b", "\U222A", "c", sep="")
diam_after_merge_edges <- c("a", buc, buc, "d")
diam_after_merge_tree <- make_directed_graph(diam_after_merge_edges)
diam_after_merge_map <- map_from_tree(diam_after_merge_tree)
diam_after_merge_disjoints <- disjoint_classes_axioms(diam_after_merge_map)

diam_after_bypass_reduce_isolate_edges <- c("a", "b\\d", "a", "c\\d", "a", "d")
diam_after_bypass_reduce_isolate_tree <- make_directed_graph(diam_after_bypass_reduce_isolate_edges)
diam_after_bypass_reduce_isolate_map <- map_from_tree(diam_after_bypass_reduce_isolate_tree)
diam_after_bypass_reduce_isolate_disjoints <- disjoint_classes_axioms(diam_after_bypass_reduce_isolate_map)

asym_initial_edges <- c(
  "a", "b", "a", "c", "b", "d", "b", "e", "c", "f", "c", "g", "e", "h", "e", "i", "i", "j"
  )
asym_initial_tree <- make_directed_graph(asym_initial_edges)
asym_initial_layout <- layout_as_tree(asym_initial_tree)
asym_initial_map <- map_from_tree(asym_initial_tree)
asym_initial_disjoints <- disjoint_classes_axioms(asym_initial_map)

asym_layout <- asym_initial_layout[]
asym_layout[c(3,6,7),1] <- asym_layout[c(3,6,7),1] + .5
asym_layout[c(3,6,7),2] <- asym_layout[c(3,6,7),2] - .5

asym_edges <- append(asym_initial_edges, c("c", "i"))
asym_tree <- make_directed_graph(asym_edges)

cue <-paste("c", "\U222A", "e", sep="")
asym_after_merge_edges <- c(
  "a", "b", "b", "d", "b", cue, "i", "j", cue, "f", cue, "g", cue, "i", cue, "h"
)
asym_after_merge_tree <- make_directed_graph(asym_after_merge_edges)
asym_after_merge_map <- map_from_tree(asym_after_merge_tree)
asym_after_merge_disjoints <- disjoint_classes_axioms(asym_after_merge_map)

asym_after_bypass_edges = c(
  "a", "b",
  "a", "c",
  "b", "d",
  "b", "e",
  "c", "f",
  "c", "g",
  "e", "h",
  "a", "i",
  "b", "i",
  "i", "j"
)
asym_after_bypass_tree <- make_directed_graph(asym_after_bypass_edges)
asym_after_bypass_layout <- asym_layout
asym_after_bypass_layout[c(9,10),1] <- asym_after_bypass_layout[c(9,10),1] + .5
asym_after_bypass_layout[c(9,10),2] <- asym_after_bypass_layout[c(9,10),2] + 1

asym_after_bypass_reduce_edges = c(
  "a", "b",
  "a", "c",
  "b", "d",
  "b", "e",
  "c", "f",
  "c", "g",
  "e", "h",
  "b", "i",
  "i", "j"
)
asym_after_bypass_reduce_tree <- make_directed_graph(asym_after_bypass_reduce_edges)
asym_after_bypass_reduce_layout <- asym_after_bypass_layout

asym_after_bypass_reduce_isolate_edges = c(
  "a", "b",
  "a", "c\\i",
  "b", "d",
  "b", "e\\i",
  "c\\i", "f",
  "c\\i", "g",
  "e\\i", "h",
  "b", "i",
  "i", "j"
)
asym_after_bypass_reduce_isolate_tree <- make_directed_graph(asym_after_bypass_reduce_isolate_edges)
asym_after_bypass_reduce_isolate_layout <- asym_after_bypass_reduce_layout
asym_after_bypass_reduce_isolate_map <- map_from_tree(asym_after_bypass_reduce_isolate_tree)
asym_after_bypass_reduce_isolate_disjoints <- disjoint_classes_axioms(asym_after_bypass_reduce_isolate_map)


