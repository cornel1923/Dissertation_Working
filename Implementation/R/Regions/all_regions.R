#install.packages("igraph")
#install.packages("ggraph")
#install.packages("reshape2")
#install.packages("disparityfilter")
#install.packages("sets")
#install.packages("networkD3")
#install.packages("zoom")

library(ggraph)
library(igraph)
library(reshape2)
library(disparityfilter)
library(sets)
library(networkD3)
library(zoom)

#map.txt
regions = read.csv(file.choose(),header=TRUE, sep=",")

source <-regions$Region;
target <-regions$Country;

label1 = c();
label2 = c();

size1 = c();
size2 = c();

for(i in 1:length(unique(source))) {
  label1[i] = 'green';
  size1[i] = 1;
}

for(i in 1:length(unique(target))) {
  size2[i] = 5;
  label2[i] = 'red';
}

array = c(array(unique(source)), array(unique(target)));

name <-unique(array)
data = c(array(size1), array(size2));
group = c(array(label1), array(label2));


MisLinks <- data.frame(source, target)

networkD3::simpleNetwork(MisLinks,
                         fontSize =20,linkDistance = 100);

MisNodes <- data.frame(name, data, group)

as.numeric(factor(MisLinks$source))-1
as.numeric(factor("aa"))-1

el <- data.frame(from=as.numeric(factor(MisLinks$source))-1, 
                 to=as.numeric(factor(MisLinks$target)))
nl <- cbind(idn=factor(MisNodes$name, levels=MisNodes$name), MisNodes) 


networkD3::forceNetwork(Links = el, Nodes = nl,
                        linkDistance =1, 
                        Source = "from", Target = "to",
                        NodeID = "name",
                        Nodesize = "data",
                        Group = "group",
                        bounded = TRUE,
                        opacityNoHover = TRUE,
                        width = 800, height = 400,
                        opacity = 1);

graphData = data.frame(source, target)

g <- graph.empty(directed = F)

node.in <- as.character(graphData$source);
node.out <- as.character(graphData$target);

g <- add.vertices(g,nv=length(node.out),attr=list(name=node.out),type=rep(FALSE,length(node.out)))
g <- add.vertices(g,nv=length(node.in),attr=list(name=node.in),type=rep(TRUE,length(node.in)))
edge.list.vec <- as.vector(t(as.matrix(data.frame(graphData))))
g <- add.edges(g,edge.list.vec)

g = delete.vertices(simplify(g), degree(g) == 0);

# define color and shape mappings.
col <- c("steelblue", "orange")
shape <- c("none")

png("mygraph.png", heigh=1000, width=800)

plot.igraph(g,vertex.shape=shape, vertex.color="red", vertex.size = 25,
            edge.color = "green", vertex.label.color= "red")

dev.off()
