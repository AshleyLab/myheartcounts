rm(list=ls())
steps=read.table("HKQuantityTypeIdentifierStepCount.4inter.txt",header=TRUE,sep='\t')
steps$Intervention=factor(steps$Intervention,levels=c("StandModule","ClusterModule","ReadAHAWebsiteModule","WalkModule"))
library(ggplot2)
p_step=ggplot(data=steps,aes(x=Intervention,y=DeltaFromBaseline,group=Intervention))+
  geom_boxplot()+
  xlab("Intervention")+
  ylab("Mean Step Count Intervention \n- Mean Step Count Baseline")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  ggtitle("Within Subject Change in Step Count\nn=2362")+
  ylim(c(-1500,1500))


