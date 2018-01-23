rm(list=ls())
library(ggplot2)
data=read.table("summary_6mwt.txt",header=TRUE,sep='\t')
ggplot(data=data,aes(x=data$Distance.m.))+
  geom_histogram()+
  xlab("Distance (m)")+
  ylab("Number of Subjects")+
  theme_bw(20)+
  ggtitle("6 Minute Walk Test (v1 & v2 combined) Distance Walked")

ggplot(data=data,aes(x=data$Steps))+
  geom_histogram()+
  xlab("Stepcount")+
  ylab("Number of Subjects")+
  theme_bw(20)+
  ggtitle("6 Minute Walk Test (v1 & v2 combined) Step Count")

