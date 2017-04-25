rm(list=ls())
library(data.table)
library(ggplot2)
source('helpers.R')
data_sit=data.frame(read.table('diff_energy_sit',header=T,sep='\t'))
dropout_sit=data.frame(read.table('dropped_energy_sit',header=T,sep='\t'))
data_sit_batch2=data.frame(read.table('diff_energy_batch2_sit',header=T,sep='\t'))
dropout_sit_batch2=data.frame(read.table('dropped_energy_batch2_sit',header=T,sep='\t'))
data_sit=merge(data_sit,data_sit_batch2,by.x="row.names",by.y="row.names",all=TRUE)
data_sit$Row.names=NULL 
data_sit$samsung=NULL 
data_sit$mio=NULL 
data_sit$pulseon=NULL 

data_sit[data_sit>0.5]=0.5
data_sit[data_sit< -0.5]=-0.5

#dropout_sit

data_walk=data.frame(read.table('diff_energy_walk',header=T,sep='\t'))
dropout_walk=data.frame(read.table('dropped_energy_walk',header=T,sep='\t'))
data_walk_batch2=data.frame(read.table('diff_energy_batch2_walk',header=T,sep='\t'))
dropout_walk_batch2=data.frame(read.table('dropped_energy_batch2_walk',header=T,sep='\t'))
data_walk=merge(data_walk,data_walk_batch2,by.x="row.names",by.y="row.names",all=TRUE)
data_walk$Row.names=NULL 
data_walk$samsung=NULL 
data_walk$mio=NULL 
data_walk$pulseon=NULL 
data_walk[data_walk>0.5]=0.5
data_walk[data_walk< -0.5]=-0.5


data_run=data.frame(read.table('diff_energy_run',header=T,sep='\t'))
dropout_run=data.frame(read.table('dropped_energy_run',header=T,sep='\t'))
data_run_batch2=data.frame(read.table('diff_energy_batch2_run',header=T,sep='\t'))
dropout_run_batch2=data.frame(read.table('dropped_energy_batch2_run',header=T,sep='\t'))
data_run=merge(data_run,data_run_batch2,by.x="row.names",by.y="row.names",all=TRUE)
data_run$Row.names=NULL
data_run$samsung=NULL 
data_run$mio=NULL 
data_run$pulseon=NULL 
data_run[data_run>0.5]=0.5
data_run[data_run< -0.5]=-0.5

data_bike=data.frame(read.table('diff_energy_bike',header=T,sep='\t'))
dropout_bike=data.frame(read.table('dropped_energy_bike',header=T,sep='\t'))
data_bike_batch2=data.frame(read.table('diff_energy_batch2_bike',header=T,sep='\t'))
dropout_bike_batch2=data.frame(read.table('dropped_energy_batch2_bike',header=T,sep='\t'))
data_bike=merge(data_bike,data_bike_batch2,by.x="row.names",by.y="row.names",all=TRUE)
data_bike$Row.names=NULL 
data_bike$samsung=NULL 
data_bike$mio=NULL 
data_bike$pulseon=NULL 
data_bike[data_bike>0.5]=0.5
data_bike[data_bike< -0.5]=-0.5


data_max=data.frame(read.table('diff_energy_max',header=T,sep='\t'))
dropout_max=data.frame(read.table('dropped_energy_max',header=T,sep='\t'))
data_max_batch2=data.frame(read.table('diff_energy_batch2_max',header=T,sep='\t'))
dropout_max_batch2=data.frame(read.table('dropped_energy_batch2_max',header=T,sep='\t'))
data_max=merge(data_max,data_max_batch2,by.x="row.names",by.y="row.names",all=TRUE)
data_max$Row.names=NULL 
data_max$samsung=NULL 
data_max$mio=NULL 
data_max$pulseon=NULL 
data_max[data_max>0.5]=0.5
data_max[data_max< -0.5]=-0.5

data_sit=melt(data_sit) 
data_walk=melt(data_walk)
data_run=melt(data_run) 
data_bike=melt(data_bike)
data_max=melt(data_max)
p1<-ggplot(data_sit,aes(variable,value))+
  geom_boxplot()+
  ylim(-0.5,0.5)+
  theme_bw(20)+ 
  xlab('Device')+
  ylab('(Steady State Kcal - Gold Std.)/Gold Std.')+
  ggtitle("Energy, Sit")+
  theme(axis.text.x=element_text(angle = -90, hjust = 0))


p2<-ggplot(data_walk,aes(variable,value))+
  geom_boxplot()+
  ylim(-0.5,0.5)+
  theme_bw(20)+ 
  xlab('Device')+
  ylab('(Steady State Kcal - Gold Std.)/Gold Std.')+
  ggtitle("Energy, walk")+
  theme(axis.text.x=element_text(angle = -90, hjust = 0))

p3<-ggplot(data_run,aes(variable,value))+
  geom_boxplot()+
  ylim(-0.5,0.5)+
  theme_bw(20)+ 
  xlab('Device')+
  ylab('(Steady State Kcal - Gold Std.)/Gold Std.')+
  ggtitle("Energy, run")+
  theme(axis.text.x=element_text(angle = -90, hjust = 0))

p4<-ggplot(data_bike,aes(variable,value))+
  geom_boxplot()+
  ylim(-0.5,0.5)+
  theme_bw(20)+ 
  xlab('Device')+
  ylab('(Steady State Kcal - Gold Std.)/Gold Std.')+
  ggtitle("Energy, bike")+
  theme(axis.text.x=element_text(angle = -90, hjust = 0))

p5<-ggplot(data_max,aes(variable,value))+
  geom_boxplot()+
  ylim(-0.5,0.5)+
  theme_bw(20)+ 
  xlab('Device')+
  ylab('(Steady State Kcal - Gold Std.)/Gold Std.')+
  ggtitle("Energy, max")+
  theme(axis.text.x=element_text(angle = -90, hjust = 0))

multiplot(p1,p2,p3,p4,p5,cols=5)
