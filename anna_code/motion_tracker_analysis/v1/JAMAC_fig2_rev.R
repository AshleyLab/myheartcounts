rm(list=ls())
library(data.table)
data=data.frame(read.table("DataFreezeDataFrame_10022015_VERSION2.tsv",sep='\t',header=T))
#attach(data)
c=chisq.test(data$cluster,data$heartCondition)
#get pairwise comparisons
#subset=data[(data$cluster==5 | data$cluster==6),]
#c=chisq.test(subset$cluster,subset$chestPain)
