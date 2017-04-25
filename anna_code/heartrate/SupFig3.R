library(data.table)
library(ggplot2)
library(reshape2)
source("helpers.R")
load("hr_walk.bin")
load("hr_rest.bin")
meta=data.frame(read.table("NonTimeSeries.txt",header=T,sep='\t'))
merged=merge(meta,hr_rest,by.x="Subject",by.y="row.names")
merged$heartCondition[merged$heartCondition %in% NA]=FALSE
merged$jointProblem[merged$jointProblem %in% NA]=FALSE 
reversed=merged$delta1*-1
merged$delta1[merged$delta1 > 0]=reversed[merged$delta1 > 0]

p1<-ggplot(merged,aes(factor(heartCondition),delta1))+
  geom_boxplot(size=2)+
  theme_bw(40)+
  ylab("6 Min Walk Recovery HR")+
  ggtitle("a")+
  xlab("")+
  scale_x_discrete(labels=c("Heart Condition","No Heart Condition")) +
  theme(plot.title=element_text(hjust=0))
p2<-ggplot(merged,aes(factor(jointProblem),delta1))+
  geom_boxplot(size=2)+
  theme_bw(40)+
  scale_x_discrete(labels=c("Joint Problem","No Joint Problem")) +
  ylab("6 Min Walk Recovery HR")+
  xlab("")+
  ggtitle("b")+
  theme(plot.title=element_text(hjust=0))


data=data.frame(read.table('deltas.small.csv',header=T,sep='\t'))
data$Condition=factor(data$Condition,levels=c('Hypertension','Vascular Disease','Joint Problems','Chest Pain','Heart Disease'))
mdf<- melt(data, id="Condition")  # convert to long format
p3=ggplot(data=mdf,
         aes(x=Condition, y=value, col=variable,group=variable,legend=FALSE)) + 
  geom_point(size=5,colour="black")+
  geom_line(size=2,colour="black")+
  theme_bw(40)+
  scale_x_discrete(labels=c("Hyper-\ntension","Vascular\nDis.","Joint\nProblems","Chest\nPain","Heart\nDisease")) +
  theme(legend.position="none")+
  xlab("\nMedical Condition")+
  ylab("Std Healthy - Std Sick\n")+
  ggtitle('c')+
  theme(plot.title=element_text(hjust=0))
multiplot(p1, p2, p3, cols=3)

#scale_color_manual(values=c("#FF0000", "#66FF33", "#0000FF","#CC9900","#CC9900","#BDA0CB"))

