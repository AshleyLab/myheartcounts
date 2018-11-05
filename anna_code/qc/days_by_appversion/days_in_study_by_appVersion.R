rm(list=ls())
library(ggplot2)
data=read.table("appVersion.tallies.collapsed.txt",header=TRUE,sep='\t',stringsAsFactors = FALSE)
data$Version=sapply(strsplit(data$Version,","), `[`, 1)
#split_vals=sapply(strsplit(data$Version,"."),'[',c(1,2))

                  

data$Version=factor(data$Version)
ggplot(data=data,
       aes(x=data$UniqueNumberDays,group=data$Version,fill=data$Version,color=data$Version))+
  geom_histogram(position="stack")+
  xlab("Days In Study")+
  ylab("Number of Users")+
  theme_bw()+
  xlim(0,30)+
  ylim(0,5000)
  #scale_color_manual(values=c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6'),name="app Version")+
  #scale_fill_manual(values=c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6'),name="app Version")+
  
ggplot(data=data,
       aes(x=data$UniqueNumberDays,group=data$Version,color=data$Version))+
  geom_density(size=2,adjust=5)+
  xlab("Days In Study")+
  ylab("Density")+
  xlim(0,30)+
  theme_bw()
  #scale_color_manual(values=c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6'),name="app Version")+
  
group1=data[data$Version=="version 2.0.3",]
group2=data[data$Version=="version 2.1.1",]
data=rbind(group1,group2)
ggplot(data=data,
       aes(x=data$UniqueNumberDays,group=data$Version,fill=data$Version,color=data$Version))+
  geom_histogram(position="dodge")+
  xlab("Days In Study")+
  ylab("Number of Users")+
  theme_bw()

ggplot(data=data,
       aes(x=data$UniqueNumberDays,group=data$Version,color=data$Version))+
  geom_density(size=2,alpha=0.3)+
  xlab("Days In Study")+
  ylab("Density")+
  theme_bw()
