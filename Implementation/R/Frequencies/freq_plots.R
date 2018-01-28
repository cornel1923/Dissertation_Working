#install.packages("igraph")
#install.packages("ggraph")
#install.packages("reshape2")
#install.packages("disparityfilter")
#install.packages("sets")

library(ggraph)
library(igraph)
library(reshape2)
library(disparityfilter)
library(sets)
library(networkD3)

ingredientsCompounds = read.csv(file.choose(),header=TRUE, sep=",")
ingredientsinfo = read.csv(file.choose(),header=TRUE, sep=",")
compoundsInfo = read.csv(file.choose(),header=TRUE, sep=",")

ingredient_name = c();
compound_name = c();
ingredient_category = c();


for(i in 1:length(ingredientsCompounds$ingredient_id)) {
  ingredientName = ingredientsinfo$ingredient_name[ingredientsinfo$id == ingredientsCompounds$ingredient_id[i]];
  ingredient_name[i] = toString(ingredientName); 
  
  categoryName = ingredientsinfo$category[ingredientsinfo$id == ingredientsCompounds$ingredient_id[i]];
  ingredient_category[i] = toString(categoryName); 
  
  compoundName = compoundsInfo$compound_name[compoundsInfo$id == ingredientsCompounds$compound_id[i]];
  compound_name[i] = toString(compoundName);
}

ingredient_id = ingredientsCompounds$ingredient_id;
compound_id = ingredientsCompounds$compound_id;

completeData = data.frame(ingredient_id, ingredient_name, ingredient_category, compound_id, compound_name);

ingredientsCategory = unique(completeData$ingredient_category)

filteredIngredients <- data.frame();

for(i in 1:length(ingredientsCategory)) {
  categoryData = completeData[completeData$ingredient_category == toString(ingredientsCategory[i]),];
  
  sortedData = names(sort(table(categoryData$ingredient_id),decreasing=TRUE))[1:1];
  filteredData = completeData[completeData$ingredient_id == sortedData,];
  filteredIngredients <- rbind(filteredIngredients, filteredData);
}

edges = filteredIngredients;

ingredients <- names(sort(table(edges$ingredient_id),decreasing=TRUE));

x <- c()
y <- c()
z <- c()
w <- c()

contor = 0;

for(i in 1:length(edges$ingredient_id)) {
  for(j in 1:length(ingredients)) {
    if (as.numeric(ingredients[j]) == as.numeric(edges$ingredient_id[i])){
      x[contor] = as.character(ingredients[j])
      y[contor] = as.character(edges$compound_id[i])
      z[contor] = as.character(edges$ingredient_name[i])
      w[contor] = as.character(edges$compound_name[i])
      contor = contor+1;
    }
  }
}

ingredient_id = x 
compound_id = y
ingredient_name = z
compound_name = w

graphData = data.frame(ingredient_name, compound_name)

g <- graph.empty(directed = F)

node.in <- as.character(graphData$ingredient_name);
node.out <- as.character(graphData$compound_name);

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

########################
from <-graphData$ingredient_name
to <-graphData$compound_name

label1 = c();
label2 = c();
category = c();
category2 = c();

testingData = unique(from);

colors = c("green", "red", "#FF7373", "003366", "#800000", "#ff7f50", "#daa520", "#0e2f44", "#404040", "#ff4444","#794044", "#daa520","#81d8d0", "#ffff66");

for(i in 1:length(testingData)) {
  label1[i] = 100;
  categoryLabel = array(unique(completeData$ingredient_category[completeData$ingredient_name == toString(testingData[i])]));
  category[i] = paste(testingData[i], ' -' ,toupper(categoryLabel));
}
for(i in 1:length(unique(to))) {
  label2[i] = 1;
  category2[i] = 'compound';
}

array = c(array(unique(from)), array(unique(to)));

name <-unique(array)
data = c(array(label1), array(label2));
categoriesData = c(array(category), array(category2));

MisLinks <- data.frame(from, to)
MisNodes <- data.frame(name, data, categoriesData)

el <- data.frame(from=as.numeric(factor(MisLinks$from))-1, 
                 to=as.numeric(factor(MisLinks$to))-1 )
nl <- cbind(idn=factor(MisNodes$name, levels=MisNodes$name), MisNodes) 

networkD3::forceNetwork(Links = el, Nodes = nl,
                        linkDistance = 10,
                        Source = "from", Target = "to",
                        NodeID = "name",
                        legend = TRUE,
                        Nodesize = "data",
                        Group = "categoriesData", width = 1200, height = 800,opacity = 1)




#######################
category = c();
ingredientName = c();
freq = c();

for(i in 1:length(ingredientsCategory)) {
  categoryData = completeData[completeData$ingredient_category == toString(ingredientsCategory[i]),];
  item = sort(table(categoryData$ingredient_id),decreasing=TRUE)[1:1];
  itemValue = as.numeric(names(item));
  
  ingredientName[i] = toString(ingredientsinfo[ingredientsinfo$id == itemValue,]$ingredient_name);
  freq[i] = as.numeric(unname(item));
  category[i] = toString(ingredientsCategory[i]);
}

graphData = data.frame(ingredientName, freq, category)

pie(graphData)


pie(graphData$freq, labels = graphData$ingredientName, 
    main="Pie Chart of Species\n (with sample sizes)", col=rainbow(length(graphData$category)))
###################
