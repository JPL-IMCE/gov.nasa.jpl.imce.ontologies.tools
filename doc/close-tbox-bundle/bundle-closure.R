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

union <- function(s) {
  paste(s, collapse="\U222A")
}

cue <- union(c("c", "e"))
asym_after_merge_edges <- c(
  "a", buc, buc, "d", buc, "e", buc, "f", buc, "g", "e", "h", "e", "i", "i", "j"
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

udlr_edges <- c(
  "t", "u",
  "t", "d",
  "t", "l",
  "t", "r",
  "u", "ul",
  "u", "ur",
  "d", "dl",
  "d", "dr",
  "l", "ul",
  "l", "dl",
  "r", "ur",
  "r", "dr"
)
udlr_tree <- make_directed_graph(udlr_edges)
udlr_layout <- matrix(c(
   0, 2,
  -2, 1,
  -1, 1,
   1, 1,
   2, 1,
  -2, 0,
  -1, 0,
   1, 0,
   2, 0
), ncol=2, byrow=TRUE)

uudulur <- union(c("u", "d", "l", "r"))
udlr_after_merge_edges <- c(
  "t", uudulur,
  uudulur, "ul",
  uudulur, "dl",
  uudulur, "ur",
  uudulur, "dr"
)
udlr_after_merge_tree = make_directed_graph(udlr_after_merge_edges)

diff_union <- function(a, b) {
  paste(a, paste("(", union(b), ")", sep=""), sep="\\")
}
udlr_after_bypass_reduce_isolate_edges <- c(
  "t", "ul",
  "t", "ur",
  "t", "dl",
  "t", "dr",
  "t", diff_union("u", c("ul", "ur")),
  "t", diff_union("d", c("dl", "dr")),
  "t", diff_union("l", c("ul", "dl")),
  "t", diff_union("r", c("ur", "dr"))
)
udlr_after_bypass_reduce_isolate_tree = make_directed_graph(udlr_after_bypass_reduce_isolate_edges)

sym8_edges <- c("a", "b", "a", "c", "b", "d", "b", "e", "c", "f", "c", "g", "e", "h", "f", "h")
sym8_tree <- make_directed_graph(sym8_edges)
sym8_layout <- layout_as_tree(sym8_tree)
sym8_layout[8,1] <- 0

sym8_after_merge_edges <- c("a", buc, buc, "d", buc, "e", buc, "f", buc, "g", "e", "h", "f", "h")
sym8_after_merge_tree <- make_directed_graph(sym8_after_merge_edges)
sym8_after_merge_layout <- layout_as_tree(sym8_after_merge_tree)
sym8_after_merge_layout[7,1] <- 0

euf <- union(c("e", "f"))
sym8_after_treeify_using_merge_edges <- c("a", buc, buc, "d", buc, euf, buc, "g", euf, "h")
sym8_after_treeify_using_merge_tree <- make_directed_graph(sym8_after_treeify_using_merge_edges)
sym8_after_treeify_using_merge_layout <- layout_as_tree(sym8_after_treeify_using_merge_tree)

sym8_after_bypass_reduce_isolate_edges <- c("a", "b", "a", "c", "b", "d\\h", "b", "e", "b", "h", "c", "f", "c", "g\\h", "c", "h")
sym8_after_bypass_reduce_isolate_tree <- make_directed_graph(sym8_after_bypass_reduce_isolate_edges)
sym8_after_bypass_reduce_isolate_layout <- layout_as_tree(sym8_after_bypass_reduce_isolate_tree)

sym8_after_treeify_using_bypass_reduce_isolate_edges <- c("a", "b\\h", "a", "h", "a", "c\\h", "b\\h", "d\\h", "b\\h", "e", "c\\h", "f", "c\\h", "g\\h")
sym8_after_treeify_using_bypass_reduce_isolate_tree <- make_directed_graph(sym8_after_treeify_using_bypass_reduce_isolate_edges)
sym8_after_treeify_using_bypass_reduce_isolate_layout <- layout_as_tree(sym8_after_treeify_using_bypass_reduce_isolate_tree)


