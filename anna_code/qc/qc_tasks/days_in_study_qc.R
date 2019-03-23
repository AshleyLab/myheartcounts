rm(list=ls())
library(ggplot2)
data=read.table("../cardiovascular-ABTestResults-v1.tsv",header=TRUE,sep='\t',row.names = 1)
p1=ggplot(data,aes(x=data$ABTestResult.days_in_study,group=data$appVersion,fill=data$appVersion))+
  geom_histogram(binwidth=1)+
  geom_vline(xintercept=7)+
  scale_fill_manual(values=c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6'))
print(p1)