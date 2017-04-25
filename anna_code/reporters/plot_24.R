rm(list=ls())
source('helpers.R')
library(ggplot2)
library(data.table)
library(PSCBS)
library(scales)
d_active_day=as.data.frame(read.table("active_weekday",header=F,sep='\t',stringsAsFactors = FALSE))
d_active_end=as.data.frame(read.table("active_weekend",header=F,sep='\t',stringsAsFactors = FALSE))
d_stat_day=as.data.frame(read.table("stationary_weekday",header=F,sep='\t',stringsAsFactors = FALSE))
d_stat_end=as.data.frame(read.table("stationary_weekend",header=F,sep='\t',stringsAsFactors = FALSE))
d_active_day$V1 <- strptime(d_active_day$V1,"%H:%M:%S")
d_active_end$V1 <- strptime(d_active_end$V1,"%H:%M:%S")
d_stat_day$V1 <- strptime(d_stat_day$V1,"%H:%M:%S")
d_stat_end$V1 <- strptime(d_stat_end$V1,"%H:%M:%S")
#browser() 
interval=1
d_active_day$V3=majorityVote(d_active_day$V3,interval)
d_active_end$V3=majorityVote(d_active_end$V3,interval)
d_stat_day$V3=majorityVote(d_stat_day$V3,interval)
d_stat_end$V3=majorityVote(d_stat_end$V3,interval)
p1<-ggplot(d_active_day,aes(x=V1,y=V3))+geom_line()+
  scale_y_discrete(limits=c(1,2,3,4,5),labels=c("Stationary","Automotive","Walking","Running","Cycling"))+theme_bw(20)+xlab("Time of Day")+ylab("Activity State")+ggtitle("Active, Weekday")
p2<-ggplot(d_active_end,aes(x=V1,y=V3))+geom_line()+
  scale_y_discrete(limits=c(1,2,3,4,5),labels=c("Stationary","Automotive","Walking","Running","Cycling"))+theme_bw(20)+xlab("Time of Day")+ylab("Activity State")+ggtitle("Active, Weekend")
p3<-ggplot(d_stat_day,aes(x=V1,y=V3))+geom_line()+
  scale_y_discrete(limits=c(1,2,3,4,5),labels=c("Stationary","Automotive","Walking","Running","Cycling"))+theme_bw(20)+xlab("Time of Day")+ylab("Activity State")+ggtitle("Sedentary, Weekday")
p4<-ggplot(d_stat_end,aes(x=V1,y=V3))+geom_line()+
  scale_y_discrete(limits=c(1,2,3,4,5),labels=c("Stationary","Automotive","Walking","Running","Cycling"))+theme_bw(20)+xlab("Time of Day")+ylab("Activity State")+ggtitle("Sedentary, Weekend")
multiplot(p1,p2,p3,p4,cols=2)