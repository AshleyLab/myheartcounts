rm=list(ls())
library(data.table)
library(ggplot2) 
library(reshape2)
source('helpers.R')
data=data.frame(read.table("Activity_states_with_watches.tsv",header=T,sep='\t'))
data$Watch=factor(data$Watch)
data$ActiveTotal=data$WalkingTotal+data$RunningTotal+data$CyclingTotal
data$ActiveWeekend=data$WalkingWeekend+data$RunningWeekend+data$CyclingWeekend
data$ActiveWeekday=data$WalkingWeekday+data$RunningWeekday+data$CyclingWeekday 
p1<-ggplot(data=data,aes(x=Watch,y=ActiveTotal))+
  geom_boxplot()+
  theme_bw(20)+
  xlab('Apple Watch Ownership')+
  ylab("Active, Total Time")+
  ggtitle('P-value=3.57e-11, Mean Delta=0.022')

p2<-ggplot(data=data,aes(x=Watch,y=ActiveWeekend))+
  geom_boxplot()+
  theme_bw(20)+
  xlab('Apple Watch Ownership')+
  ylab("Active, Weekend")+
  ggtitle('P-value <2e-16, Mean Delta=0.056')
p3<-ggplot(data=data,aes(x=Watch,y=ActiveWeekday))+
  geom_boxplot()+
  theme_bw(20)+
  xlab('Apple Watch Ownership')+
  ylab("Active, Workweek")+
  ggtitle('P-value=6.47e-14, Mean Delta=0.026')
multiplot(p1,p2,p3,cols=3)

p4<-ggplot(data=data,aes(x=Watch,y=WalkingTotal))+
  geom_boxplot()+
  theme_bw(20)+
  xlab('Apple Watch Ownership')+
  ylab("Walking, Total")+
  ggtitle('P-value=<2e-16, Mean Delta=0.023')

p5<-ggplot(data=data,aes(x=Watch,y=WalkingWeekend))+
  geom_boxplot()+
  theme_bw(20)+
  xlab('Apple Watch Ownership')+
  ylab("Walking, Weekend")+
  ggtitle('P-value <2e-16, Mean Delta=0.034')
p6<-ggplot(data=data,aes(x=Watch,y=WalkingWeekday))+
  geom_boxplot()+
  theme_bw(20)+
  xlab('Apple Watch Ownership')+
  ylab("Walking, WorkWeek")+
  ggtitle('P-value=<2e-16, Mean Delta=0.026')
multiplot(p4,p5,p6,cols=3)


p7<-ggplot(data=data,aes(x=Watch,y=RunningTotal))+
  geom_boxplot()+
  theme_bw(20)+
  xlab('Apple Watch Ownership')+
  ylab("Running, Total")+
  ggtitle('P-value=3.68e-4, Mean Delta=8.1e-4')

p8<-ggplot(data=data,aes(x=Watch,y=RunningWeekend))+
  geom_boxplot()+
  theme_bw(20)+
  xlab('Apple Watch Ownership')+
  ylab("Running, Weekend")+
  ggtitle('P-value <2e-16, Mean Delta=0.034')
p9<-ggplot(data=data,aes(x=Watch,y=RunningWeekday))+
  geom_boxplot()+
  theme_bw(20)+
  xlab('Apple Watch Ownership')+
  ylab("Running, Workweek")+
  ggtitle('P-value=1.28e-3, Mean Delta=9.57e-4')
multiplot(p7,p8,p9,cols=3)

p10<-ggplot(data=data,aes(x=Watch,y=CyclingTotal))+
  geom_boxplot()+
  theme_bw(20)+
  xlab('Apple Watch Ownership')+
  ylab("Cycling, Total")+
  ggtitle('P-value=0.215 (No significant difference)')
p11<-ggplot(data=data,aes(x=Watch,y=CyclingWeekend))+
  geom_boxplot()+
  theme_bw(20)+
  xlab('Apple Watch Ownership')+
  ylab("Cycling, Weekend")+
  ggtitle('P-value <2e-16, Mean Delta=0.021')
p12<-ggplot(data=data,aes(x=Watch,y=CyclingWeekday))+
  geom_boxplot()+
  theme_bw(20)+
  xlab('Apple Watch Ownership')+
  ylab("Cycling, Weekday")+
  ggtitle('P-value=0.821 (No significant difference)')
multiplot(p10,p11,p12,cols=3)

multiplot(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,cols=4)
