rm(list=ls())
data=read.table("demographics.rct.tsv",header=TRUE,sep='\t')
library(ggplot2)
ggplot(data,
       aes(x=data$Age,
           group=data$Sex,
           fill=data$Sex))+
  geom_histogram(stat="count",
                 position="stack")+
  xlab("Age")+
  ylab("Number of Participants")+
  scale_fill_manual(values=c("#1b9e77","#d95f02","#7570b3"),
                             name="Biological Sex")+
  theme_bw(20)