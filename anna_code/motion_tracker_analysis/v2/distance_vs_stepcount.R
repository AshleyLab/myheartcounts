rm(list=ls())
data=read.table("distance_vs_steps_healthkit.txt",header=TRUE,sep='\t')
library(ggplot2)
#remove outliers 
data=data[data$Distance<=50000,]
data=data[data$Steps<=50000,]

p=ggplot(data,aes(x=data$Distance,y=data$Steps,group=data$Intervention,color=data$Intervention))+
  geom_point(alpha=1)+
  xlab("Distance(m)")+
  ylab("Steps")+
  theme_bw(20)
print(p)

#plot the subsets 
data_cluster=data[data$Intervention=="cluster",]
p=ggplot(data_cluster,aes(x=Distance,y=Steps,group=Intervention,color=Intervention))+
  geom_point(alpha=0.1)+
  xlab("Distance(m)")+
  ylab("Steps")+
  theme_bw(20)
print(p)

data_none=data[data$Intervention=="None",]
p=ggplot(data_none,aes(x=Distance,y=Steps,group=Intervention,color=Intervention))+
  geom_point(alpha=0.1)+
  xlab("Distance(m)")+
  ylab("Steps")+
  theme_bw(20)
print(p)

data_na=data[data$Intervention=="NotEnrolled",]
p=ggplot(data_na,aes(x=Distance,y=Steps,group=Intervention,color=Intervention))+
  geom_point(alpha=0.1)+
  xlab("Distance(m)")+
  ylab("Steps")+
  theme_bw(20)
print(p)

data_read=data[data$Intervention=="read_aha",]
p=ggplot(data_read,aes(x=Distance,y=Steps,group=Intervention,color=Intervention))+
  geom_point(alpha=0.1)+
  xlab("Distance(m)")+
  ylab("Steps")+
  theme_bw(20)
print(p)

data_stand=data[data$Intervention=="stand",]
p=ggplot(data_stand,aes(x=Distance,y=Steps,group=Intervention,color=Intervention))+
  geom_point(alpha=0.1)+
  xlab("Distance(m)")+
  ylab("Steps")+
  theme_bw(20)
print(p)

data_walk=data[data$Intervention=="walk",]
p=ggplot(data_walk,aes(x=Distance,y=Steps,group=Intervention,color=Intervention))+
  geom_point(alpha=0.1)+
  xlab("Distance(m)")+
  ylab("Steps")+
  theme_bw(20)
print(p)



