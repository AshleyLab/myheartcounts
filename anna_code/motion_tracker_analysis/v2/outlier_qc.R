rm(list=ls())
library(ggplot2)
data=read.table("outliers.txt",header=TRUE,sep='\t')
#color by Step Source Device 
p1=ggplot(data=data,
          aes(x=Step,y=Dist,
          group=StepSource,
          color=StepSource,
          alpha=0.1))+
  geom_point()+
  xlab("HealthKit Steps")+
  ylab("HealthKit Distance")+
  scale_x_continuous(trans='log10')+
  scale_y_continuous(trans='log10') 

#color by Distance Source Device 
p2=ggplot(data=data,
          aes(x=Step,y=Dist,
              group=DistSource,
              color=DistSource,
              alpha=0.1))+
  geom_point()+
  xlab("HealthKit Steps")+
  ylab("HealthKit Distance")+
  scale_x_continuous(trans='log10')+
  scale_y_continuous(trans='log10') 


library(reshape2)
stepsource_outliers=melt(table(data$StepSource))
stepsource_outliers=stepsource_outliers[order(-stepsource_outliers$value),]
stepsource_outliers$Var1=factor(stepsource_outliers$Var1,levels=stepsource_outliers$Var1)
p3=ggplot(data=stepsource_outliers,
          aes(
          x=Var1,
          y=value))+
  geom_histogram(stat="identity")+
  xlab("Source of Step Count")+
  ylab("Subject/Day Outliers")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


distsource_outliers=melt(table(data$DistSource))
distsource_outliers=distsource_outliers[order(-distsource_outliers$value),]
distsource_outliers$Var1=factor(distsource_outliers$Var1,levels=distsource_outliers$Var1)
p4=ggplot(data=distsource_outliers,
          aes(
            x=Var1,
            y=value))+
  geom_histogram(stat="identity")+
  xlab("Source of Distance Count")+
  ylab("Subject/Day Outliers")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
