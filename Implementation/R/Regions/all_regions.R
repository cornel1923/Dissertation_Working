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

#map.txt
regions = read.csv(file.choose(),header=TRUE, sep=",")
regions$Country =  as.character(regions$Country)

regions$Country[regions$Country == 'EasternEuropean_Russian'] <- 'Russia' 
regions$Country[regions$Country == 'UK-and-Ireland'] <- 'United Kingdom' 
regions$Country[regions$Country == 'Greek'] <- 'Greece' 
regions$Country[regions$Country == 'Moroccan'] <- 'Morocco' 
regions<-rbind(regions, data.frame(Country='Ireland',Region='WesternEuropean'))

regions$Country =  as.factor(regions$Country)

allData <- joinCountryData2Map(regions, joinCode = "NAME", nameJoinColumn = "Country",nameCountryColumn = "Name")
DATA = allData;
n = length(DATA$Country);

DATA <- DATA[!is.na(DATA$Country),]
colors = rainbow(n, s = 1, v = 0.5, start = 0, end = max(1, n - 1)/n, alpha = 1)

#colors = c();
#qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
#col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
#color = grDevices::colors()[grep('gr(a|e)y', grDevices::colors(), invert = T)]

#for(i in 1:length(allData$Country)) {
  #colors[i] = color[i];
#}

mapCountryData(DATA
                , nameColumnToPlot='NAME'
                , catMethod = 'categorical'
                , mapTitle='Countries'
                , colourPalette=colors
                , oceanCol='white',
                  missingCountryCol = "red"
                , addLegend  = FALSE)

# get the coordinates for each country
country_coord<-data.frame(coordinates(DATA),stringsAsFactors=F)
# label the countries
text(x=country_coord$X1,y=country_coord$X2,labels=row.names(country_coord), 
     cex = 0.2, col = "white")

