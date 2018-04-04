#install.packages("igraph")
#install.packages("ggraph")
#install.packages("reshape2")
#install.packages("disparityfilter")
#install.packages("sets")
#install.packages("networkD3")
#install.packages("zoom")
#install.packages("rworldmap")

library(ggraph)
library(igraph)
library(reshape2)
library(disparityfilter)
library(sets)
library(networkD3)
library(zoom)
library(rworldmap)
library(RColorBrewer)

convertIngredientsCSVNamesToId <- function(con, fileName) {
  while (length(oneLine <- readLines(con, n = 1)) > 0) {
    myLine <- unlist((strsplit(oneLine, ",")))
    
    idsList <- c();
    for(i in 1:length(myLine)){
      idsList[i] = toString(ingredientsinfo$id[ingredientsinfo$ingredient_name == myLine[i]]);
    }
    
    FF <- as.matrix(t(idsList))
    write.table(FF, file = fileName, sep = ",", 
                col.names = FALSE, append=TRUE)  
  } 
  close(con)
}


ingredientsinfo = read.csv(file.choose(),header=TRUE, sep=",")

con <- file(file.choose(), open = "r")
convertIngredientsCSVNamesToId(con, "italian.csv")

con <- file(file.choose(), open = "r")
convertIngredientsCSVNamesToId(con, "italian.csv")
