rm(list=ls())
library(data.table)
library(ggplot2)
source('helpers.R')
data_sit=data.frame(read.table('diff_hr_sit',header=T,sep='\t'))
dropout_sit=data.frame(read.table('dropped_hr_sit',header=T,sep='\t'))
data_sit_batch2=data.frame(read.table('diff_hr_batch2_sit',header=T,sep='\t'))
dropout_sit_batch2=data.frame(read.table('dropped_hr_batch2_sit',header=T,sep='\t'))
data_sit=merge(data_sit,data_sit_batch2,by.x="row.names",by.y="row.names",all=TRUE)
data_sit$Row.names=NULL 
data_sit[data_sit>50]=50
data_sit[data_sit< -50]=-50

#dropout_sit

data_walk=data.frame(read.table('diff_hr_walk',header=T,sep='\t'))
dropout_walk=data.frame(read.table('dropped_hr_walk',header=T,sep='\t'))
data_walk_batch2=data.frame(read.table('diff_hr_batch2_walk',header=T,sep='\t'))
dropout_walk_batch2=data.frame(read.table('dropped_hr_batch2_walk',header=T,sep='\t'))
data_walk=merge(data_walk,data_walk_batch2,by.x="row.names",by.y="row.names",all=TRUE)
data_walk$Row.names=NULL 
data_walk[data_walk>50]=50
data_walk[data_walk< -50]=-50


data_run=data.frame(read.table('diff_hr_run',header=T,sep='\t'))
dropout_run=data.frame(read.table('dropped_hr_run',header=T,sep='\t'))
data_run_batch2=data.frame(read.table('diff_hr_batch2_run',header=T,sep='\t'))
dropout_run_batch2=data.frame(read.table('dropped_hr_batch2_run',header=T,sep='\t'))
data_run=merge(data_run,data_run_batch2,by.x="row.names",by.y="row.names",all=TRUE)
data_run$Row.names=NULL 
data_run[data_run>50]=50
data_run[data_run< -50]=-50

data_bike=data.frame(read.table('diff_hr_bike',header=T,sep='\t'))
dropout_bike=data.frame(read.table('dropped_hr_bike',header=T,sep='\t'))
data_bike_batch2=data.frame(read.table('diff_hr_batch2_bike',header=T,sep='\t'))
dropout_bike_batch2=data.frame(read.table('dropped_hr_batch2_bike',header=T,sep='\t'))
data_bike=merge(data_bike,data_bike_batch2,by.x="row.names",by.y="row.names",all=TRUE)
data_bike$Row.names=NULL 
data_bike[data_bike>50]=50
data_bike[data_bike< -50]=-50


data_max=data.frame(read.table('diff_hr_max',header=T,sep='\t'))
dropout_max=data.frame(read.table('dropped_hr_max',header=T,sep='\t'))
data_max_batch2=data.frame(read.table('diff_hr_batch2_max',header=T,sep='\t'))
dropout_max_batch2=data.frame(read.table('dropped_hr_batch2_max',header=T,sep='\t'))
data_max=merge(data_max,data_max_batch2,by.x="row.names",by.y="row.names",all=TRUE)
data_max$Row.names=NULL 
data_max[data_max>50]=50
data_max[data_max< -50]=-50

data_sit=melt(data_sit) 
data_walk=melt(data_walk)
data_run=melt(data_run) 
data_bike=melt(data_bike)
data_max=melt(data_max)
p1<-ggplot(data_sit,aes(variable,value))+
  geom_boxplot()+
  ylim(-50,50)+
  theme_bw(20)+ 
  xlab('Device')+
  ylab('(Steady State BPM - Gold Std.)')+
  ggtitle("Heart Rate, Sit")+
  theme(axis.text.x=element_text(angle = -90, hjust = 0))


p2<-ggplot(data_walk,aes(variable,value))+
  geom_boxplot()+
  ylim(-50,50)+
  theme_bw(20)+ 
  xlab('Device')+
  ylab('(Steady State BPM - Gold Std.)')+
  ggtitle("Heart Rate, walk")+
  theme(axis.text.x=element_text(angle = -90, hjust = 0))

p3<-ggplot(data_run,aes(variable,value))+
  geom_boxplot()+
  ylim(-50,50)+
  theme_bw(20)+ 
  xlab('Device')+
  ylab('(Steady State BPM - Gold Std.)')+
  ggtitle("Heart Rate, run")+
  theme(axis.text.x=element_text(angle = -90, hjust = 0))

p4<-ggplot(data_bike,aes(variable,value))+
  geom_boxplot()+
  ylim(-50,50)+
  theme_bw(20)+ 
  xlab('Device')+
  ylab('(Steady State BPM - Gold Std.)')+
  ggtitle("Heart Rate, bike")+
  theme(axis.text.x=element_text(angle = -90, hjust = 0))

p5<-ggplot(data_max,aes(variable,value))+
  geom_boxplot()+
  ylim(-50,50)+
  theme_bw(20)+ 
  xlab('Device')+
  ylab('(Steady State BPM - Gold Std.)')+
  ggtitle("Heart Rate, max")+
  theme(axis.text.x=element_text(angle = -90, hjust = 0))

multiplot(p1,p2,p3,p4,p5,cols=5)
