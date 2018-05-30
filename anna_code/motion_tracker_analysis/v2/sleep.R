rm(list=ls())
library(ggplot2)
data=read.table("sleep_healthkit_combined.nonan.txt",header=TRUE,sep='\t')
#remove extreme outliers (i.e. < 4hours, > 15 hours)
data=data[data$Value <54000,]
data=data[data$Value > 14400,]
data$Value=data$Value/3600
data$Intervention=factor(data$Intervention)
sleep_step_fit=lm(Value~Intervention+dayIndex+Intervention*dayIndex,data=data)

p=ggplot(data=data,aes(x=data$Intervention,y=Value))+
  geom_boxplot()+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  xlab("Intervention")+
  ylab("Sleep Duration in Hours")+
  ggtitle("Duration of Sleep")
  
