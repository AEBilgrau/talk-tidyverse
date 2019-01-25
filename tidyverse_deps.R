library("pkggraph")
pkggraph::init(local = TRUE)
tidyverse_pkgs <- c("tidyverse",
                    "tibble", "dplyr", "tidyr", "readr", "forcats", "purrr",
                    "stringr", "ggplot2")
tidyverse_pkgs_deps <- pkggraph::get_all_dependencies(tidyverse_pkgs,
                                                      level = 1L,
                                                      relation = "Imports")
tidyverse_graph <- pkggraph::make_neighborhood_graph(tidyverse_pkgs_deps)


graph_object <- tidyverse_graph[[1]]
edgeList <- data.frame(SourceName = igraph::get.edgelist(graph_object)[,1],
                       Weight = igraph::get.edge.attribute(graph_object, "relation"),
                       TargetName = igraph::get.edgelist(graph_object)[,2])
nodeList <- data.frame(ID = c(0:(igraph::gorder(graph_object) - 1)),
                       nName = igraph::V(graph_object)$name,
                       group = ifelse(igraph::V(graph_object)$name %in% tidyverse_pkgs[-1],
                                      4, 2))
nodeList$group[nodeList$nName == "tidyverse"] <- 6

getNodeID <- function(x) {
  which(x == igraph::V(graph_object)$name) - 1L
}
getNodeID <- Vectorize(getNodeID)
edgeList[["SourceID"]] <- getNodeID(edgeList[["SourceName"]])
edgeList[["TargetID"]] <- getNodeID(edgeList[["TargetName"]])
edgeList$value <- unclass(edgeList$Weight)

colCodes        <- c("#E41A1C", "#1B00FF", "#4DAF4A",   "#984EA3",  "#FF7F00")
names(colCodes) <- c("Depends", "Imports", "LinkingTo", "Suggests", "Enhances")

edges_col <- colCodes[as.character(edgeList$Weight)]

colourScale <- networkD3::JS("d3.scaleOrdinal(d3.schemeCategory20);")
#colourScale <- networkD3::JS("d3.scaleOrdinal().range([\"#000000\"]);")

js_code <- " d3.select(this).select(\"circle\")\n  .transition().duration(750).attr(\"r\", 20)"
height <- 550
width <- 750
networkD3::forceNetwork(Links = edgeList,
                        Nodes = nodeList,
                        Source = "SourceID",
                        Target = "TargetID",
                        Value = "value",
                        NodeID = "nName",
                        colourScale = colourScale,
                        Nodesize = "group",
                        Group = "group",
                        opacity = 1,
                        zoom = TRUE,
                        opacityNoHover = 1,
                        arrows = TRUE,
                        linkColour = edges_col,
                        radiusCalculation = 7,
                        fontSize = 14,
                        fontFamily = "serif",
                        height = height,
                        width = width,
                        clickAction = js_code,
                        charge = -200,
                        linkDistance = 65,
                        bounded = TRUE)
