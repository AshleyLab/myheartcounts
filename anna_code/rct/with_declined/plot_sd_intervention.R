data=read.table("mean_intervention_deltas.txt",header=FALSE,sep='\t')
names(data)=c("Subject","Intervention","MeanDelta")
library(ggplot2)
ggplot(data,aes(y=data$MeanDelta,group=data$Intervention,color=data$Intervention))+
  geom_boxplot()+
  ylim(-1000,1000)

sd(data[data$Intervention=="cluster",]$MeanDelta)
sd(data[data$Intervention=="walk",]$MeanDelta)
sd(data[data$Intervention=="read_aha",]$MeanDelta)
sd(data[data$Intervention=="stand",]$MeanDelta)
