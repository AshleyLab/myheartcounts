rm(list=ls())
library(ggplot2)
data=read.table("demographics_summary_v1_v2.tsv",header=TRUE,sep='\t')
data$Version=factor(data$Version)
v1=data[data$Version==1,]
v2=data[data$Version==2,]
ggplot(data=v1,aes(x=v1$Age))+geom_histogram(stat="count")+
  xlim(18,100)+
  theme_bw(20)+
  xlab("Age (years)")+
  ylab("Number of subjects")+
  ggtitle("Version 1 Age Distribution")


ggplot(data=v2,aes(x=v2$Age))+geom_histogram(stat="count")+
  xlim(18,100)+
  theme_bw(20)+
  xlab("Age (years)")+
  ylab("Number of subjects")+
  ggtitle("Version 2 Age Distribution")


ggplot(data=v1,aes(x=v1$Sex))+geom_histogram(stat="count")+
  theme_bw(20)+
  xlab("Biological Sex")+
  ylab("Number of subjects")+
  ggtitle("Version 1 Biological Sex")


ggplot(data=v2,aes(x=v2$Sex))+geom_histogram(stat="count")+
  theme_bw(20)+
  xlab("Biological Sex")+
  ylab("Number of subjects")+
  ggtitle("Version 2 Biological Sex")


ggplot(data=v1,aes(x=v1$Ancestry))+geom_histogram(stat="count")+
  theme_bw(20)+
  xlab("Ethnicity")+
  ylab("Number of subjects")+
  ggtitle("Version 1 Ethnicity")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


ggplot(data=v2,aes(x=v2$Ancestry))+geom_histogram(stat="count")+
  theme_bw(20)+
  xlab("Ethnicity")+
  ylab("Number of subjects")+
  ggtitle("Version 2 Ethnicity")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

