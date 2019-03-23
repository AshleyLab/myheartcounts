rm(list=ls())
steps=read.table("HKQuantityTypeIdentifierStepCount.txt",header=TRUE,sep='\t')
dist=read.table("HKQuantityTypeIdentifierDistance.txt",header=TRUE,sep='\t')
library(ggplot2)
p_step=ggplot(data=steps,aes(x=Intervention,y=DeltaFromBaseline,group=Intervention))+
  geom_boxplot()+
  xlab("Intervention")+
  ylab("Mean Step Count Intervention \n- Mean Step Count Baseline")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  ylim(c(-5000,5000))

p_dist=ggplot(data=dist,aes(x=Intervention,y=DeltaFromBaseline,group=Intervention))+
  geom_boxplot()+
  xlab("Intervention")+
  ylab("Mean Distance Walked (m) Intervention \n- Mean Ditance Walked (m) Baseline")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  ylim(c(-5000,5000))

