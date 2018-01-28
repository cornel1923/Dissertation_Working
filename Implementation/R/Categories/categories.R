#install.packages("igraph")
#install.packages("ggraph")
#install.packages("reshape2")
#install.packages("disparityfilter")
#install.packages("sets")
install.packages("networkD3")
install.packages("zoom")

library(ggraph)
library(igraph)
library(reshape2)
library(disparityfilter)
library(sets)
library(networkD3)
library(zoom)

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

edges <- data.frame();

test = c();
for(i in 1:length(ingredientsCategory)) {
  categoryData = completeData[completeData$ingredient_category == toString(ingredientsCategory[i]),];
  categoryLength = length(unique(categoryData$ingredient_id));
  categoryName = ingredientsCategory[i];
  test[i] = as.character(categoryLength);
}

category_name = ingredientsCategory;
category_ingredients = test;

graphData = data.frame(category_name, category_ingredients);
ggplot(graphData, aes(x=graphData$category_name, y=seq(1,length(graphData$category_name)),col=graphData$category_ingredients, shape=graphData$category_ingredients)) + geom_point()


colors = c("green", "red", "#FF7373", "003366", "#800000", "#ff7f50", "#daa520", "#0e2f44", "#404040", "#ff4444","#794044", "#daa520","#81d8d0", "#ffff66");


source <-graphData$category_ingredients
target <-graphData$category_ingredients
value=c(1,1,1,1,1,1,1,1,1,1,1,1,1,1);
name <-category_name

data = source
MisLinks <- data.frame(source, target, value)
MisNodes <- data.frame(name, colors, data)


el <- data.frame(from=as.numeric(factor(MisLinks$source))-1, 
                 to=as.numeric(factor(MisLinks$target))-1 )
nl <- cbind(idn=factor(MisNodes$name, levels=MisNodes$name), MisNodes) 

networkD3::forceNetwork(Links = el, Nodes = nl,
             linkDistance = 1,
             Source = "from", Target = "to",
             NodeID = "name", Nodesize = "data",
             fontSize = 20, 
             legend = TRUE,
             Group = "name", width = 1200, height = 800,opacity = 1)
