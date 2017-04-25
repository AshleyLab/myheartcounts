rm(list=ls())
library(data.table)
library(ggplot2)
library(reshape2)

par(mar=c(20, 4, 5, 0) + 0.7)

data=data.frame(read.table('delta_emotions.csv',header=T,sep='\t'))
mdf<- melt(data, id="Satisfaction")  # convert to long format
mdf$Satisfaction=factor(mdf$Satisfaction,levels=c("Depressed (p=3.23e-4)","Worried (p=0.00)","Satisfied (p=0.00)","Happy (p=0.00)","Worthwhile (p=2.23e-4)"))
mdf$variable=factor(mdf$variable,levels=c("Active","Weekend.Warriors","Inactive","Drivers"))
p=ggplot(data=mdf,
         aes(x=Satisfaction, y=value, col=variable,group=variable)) + 
  geom_point(size=5)+
  geom_line()+
  theme_bw(20)+
  xlab("Life Satisfaction Criterion")+
  ylab("")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
#scale_color_manual(values=c("#FF0000", "#66FF33", "#0000FF","#CC9900","#CC9900","#BDA0CB"))
browser() 

#mids <- barplot(data$Delta,ylim=c(-10,10),ylab="Active Cluster - Inactive Cluster % Diff",names.arg=data$Satisfaction,cex.axis=1.5, cex.lab=1.5,cex.names=1.5,las=2)

data=data.frame(read.table('illness.small.2.csv',header=T,sep='\t'))
mdf<- melt(data, id="Condition")  # convert to long format
mdf$variable=factor(mdf$variable,levels=c("Active","Weekend.Warriors","Inactive","Drivers"))

p=ggplot(data=mdf,
         aes(x=Condition, y=value, col=variable,group=variable)) + 
  geom_point(size=5)+
  geom_line()+
  theme_bw(20)+
  xlab("Heart disease p=1.67e-5")+
  ylab("% with Condition")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
#scale_color_manual(values=c("#FF0000", "#66FF33", "#0000FF","#CC9900","#CC9900","#BDA0CB"))

