rm(list=ls())
library(data.table)
#ALL FEATURES 
#PCA 
d<-as.data.frame(read.table("motiontracker_data.txt",row.name=1,header=T)) 
wavelets<-d[,1:10] 
proportions<-d[,21:length(names(d))]

#DELTA OF WEEKEND AND WEEKDAY ACTIVITY 
delta_w1<-(d$day1-d$end1)
delta_w2<-(d$day2-d$end2)
delta_w3<-(d$day3-d$end3) 
delta_w4<-(d$day4-d$end4) 
delta_w5<-(d$day5-d$end5) 
delta_w6<-(d$day6-d$end6)
delta_w7<-(d$day7-d$end7)
delta_w8<-(d$day8-d$end8)
delta_w9<-(d$day9-d$end9)
delta_w10<-(d$day10-d$end10)
delta_automotive<-(d$automotive_day-d$automative_end)
delta_stationary<-(d$stationary_day-d$stationary_end)
delta_unknown<-(d$unknown_day-d$unknown_end)
delta_walking<-(d$walking_day-d$walking_end)
delta_cycling<-(d$cycling_day-d$cycling_end)
delta_running<-(d$running_day-d$running_end)
delta_num_datapoints<-abs(d$num_datapoints_day-d$num_datapoints_end)
delta_mean_interval<-abs(d$mean_interval_day-d$mean_interval_end)
deltas<-data.frame(delta_w1,delta_w2,delta_w3,delta_w4,delta_w5,delta_w6,delta_w7,delta_w8,delta_w9,delta_w10,delta_automotive,delta_stationary,delta_unknown,delta_walking,delta_cycling,delta_running,delta_num_datapoints,delta_mean_interval,row.names=row.names(d)) 

deltas_wavelets<-deltas[,1:10] 
deltas_proportions<-deltas[,11:length(names(deltas))]


# use silhouette width to determine optimal # clusters 
#library(fpc)
#library(cluster) 
#asw <- numeric(10)
#for (k in 2:10)
#  asw[[k]] <- pam(d, k) $ silinfo $ avg.width
#k.best <- which.max(asw)
#cat("silhouette-optimal number of clusters:", k.best, "\n")


######DO CLUSTERING!!##################
km.d=kmeans(d,10,nstart=50) 
save(km.d,file="object_km.d")
km.delta=kmeans(deltas,10,nstart=50) 
save(km.delta,file="object_km.delta") 
