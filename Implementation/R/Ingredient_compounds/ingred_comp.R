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

###################
ingredientName = 'garlic';
mainIngredientCompounds = which(completeData$ingredient_name == ingredientName);
mainIngredientId = c();
mainIngredientCompound = c(); 
label1 = c(100);
category = c(1);
label2 = c();
category2 = c();

array = completeData$compound_name;
for(i in 1:length(mainIngredientCompounds)) {
  mainIngredientId[i] = ingredientName;
  mainIngredientCompound[i] = toString(array[as.numeric(mainIngredientCompounds[i])])
  label2[i] = 1;
  category2[i] = 100;
}


from = mainIngredientId;
to = mainIngredientCompound;

array = c(array(unique(from)), array(unique(to)));
name <-unique(array)
data = c(array(label1), array(label2));
categoriesData = c(array(category), array(category2));

MisLinks <- data.frame(from, to)

MisNodes <- data.frame(name, data, categoriesData)

el <- data.frame(from=as.numeric(factor(MisLinks$from))-1, 
                 to=as.numeric(factor(MisLinks$to))-1 );

nl <- cbind(idn=factor(MisNodes$name, levels=ingredientName), MisNodes);



networkD3::forceNetwork(Links = el, Nodes = nl,
                        linkDistance =200, 
                        Source = "from", Target = "to",
                        NodeID = "name",
                        Nodesize = "data",
                        Group = "categoriesData",
                        bounded = TRUE,
                        opacityNoHover = TRUE,
                        width = 800, height = 400,
                        opacity = 1);



