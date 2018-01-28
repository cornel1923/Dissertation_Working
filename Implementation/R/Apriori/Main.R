library(Matrix)
library(arules)
library(dplyr)

#data = read.table("caribbean.txt", sep="\n");
#write(data, file = "data", sept);

trans = read.transactions("all_categories.txt", format = "basket", sep=",");

inspect(trans);
#---------------#
itemFrequencyPlot(trans,topN=20,type="absolute")

#---------------#

rules = apriori(trans, parameter=list(support=0.02, confidence=0.9, minlen=2));

rules <- sort(rules, by ="lift")
rules<-sort(rules, by="confidence", decreasing=TRUE)

data <- as(rules, "data.frame")

write.csv(file="Test", x=data)

#---------------#
arules<-apriori(trans, parameter=list(supp=0.001,conf = 0.08), 
               appearance = list(default="lhs",rhs="olive_oil"),
               control = list(verbose=F))
rules<-sort(rules, decreasing=TRUE,by="confidence")
inspect(rules[1:5])

#---------------#
#---------------#
rules<-apriori(data=trans, parameter=list(supp=0.001,conf = 0.15,minlen=2), 
               appearance = list(default="rhs",lhs="rice"),
               control = list(verbose=F))
rules<-sort(rules, decreasing=TRUE,by="confidence")
inspect(rules[1:5])
#---------------#

#---------------#
library(arulesViz)
plot(rules,method="graph",interactive=TRUE,shading=NA)


library(arulesViz)
library(grid)
plot(rules)
plot(rules, method = "grouped", control = list(k = 5))
plot(rules, method="graph", control=list(type="items"))
plot(rules, method="graph", control=list(type="itemsets"))
plot(rules, method="paracoord",  control=list(alpha=.5, reorder=TRUE))
plot(rules,measure=c("support","lift"),shading="confidence",interactive=T)
