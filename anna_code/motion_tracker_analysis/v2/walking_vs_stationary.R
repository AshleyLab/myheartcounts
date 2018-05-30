rm(list=ls())
data=read.table("~/mhc/walking_vs_stationary.txt",header=TRUE,sep='\t')
library(ggplot2)
#remove outliers 
data=data[data$Walking<=300,]
data=data[data$Stationary<=1440,]
p=ggplot(data,aes(x=data$Walking,y=data$Stationary,group=data$Intervention,color=data$Intervention))+
  geom_point()+
  xlab("Walking(m)")+
  ylab("Stationary")+
  theme_bw(20)
print(p)

#plot teh subsets 
data_cluster=data[data$Intervention=="cluster",]
p=ggplot(data_cluster,aes(x=Walking,y=Stationary,group=Intervention,color=Intervention))+
  geom_point()+
  xlab("Walking(m)")+
  ylab("Stationary")+
  theme_bw(20)
print(p)

data_none=data[data$Intervention=="None",]
p=ggplot(data_none,aes(x=Walking,y=Stationary,group=Intervention,color=Intervention))+
  geom_point()+
  xlab("Walking(m)")+
  ylab("Stationary")+
  theme_bw(20)
print(p)

data_na=data[data$Intervention=="NotEnrolled",]
p=ggplot(data_na,aes(x=Walking,y=Stationary,group=Intervention,color=Intervention))+
  geom_point()+
  xlab("Walking(m)")+
  ylab("Stationary")+
  theme_bw(20)
print(p)

data_read=data[data$Intervention=="read_aha",]
p=ggplot(data_read,aes(x=Walking,y=Stationary,group=Intervention,color=Intervention))+
  geom_point()+
  xlab("Walking(m)")+
  ylab("Stationary")+
  theme_bw(20)
print(p)

data_stand=data[data$Intervention=="stand",]
p=ggplot(data_stand,aes(x=Walking,y=Stationary,group=Intervention,color=Intervention))+
  geom_point()+
  xlab("Walking(m)")+
  ylab("Stationary")+
  theme_bw(20)
print(p)

data_walk=data[data$Intervention=="walk",]
p=ggplot(data_walk,aes(x=Walking,y=Stationary,group=Intervention,color=Intervention))+
  geom_point()+
  xlab("Walking(m)")+
  ylab("Stationary")+
  theme_bw(20)
print(p)



