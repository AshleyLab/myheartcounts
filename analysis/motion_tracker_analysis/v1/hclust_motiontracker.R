rm(list=ls())
library(data.table)
#ALL FEATURES 
#PCA 
d<-as.data.frame(read.table("motiontracker_data.txt",row.name=1,header=T)) 
wavelets<-d[,1:20] 
proportions<-d[,21:length(names(d))]

#DELTA OF WEEKEND AND WEEKDAY ACTIVITY 
delta_w1<-abs(d$day1-d$end1)
delta_w2<-abs(d$day2-d$end2)
delta_w3<-abs(d$day3-d$end3) 
delta_w4<-abs(d$day4-d$end4) 
delta_w5<-abs(d$day5-d$end5) 
delta_w6<-abs(d$day6-d$end6)
delta_w7<-abs(d$day7-d$end7)
delta_w8<-abs(d$day8-d$end8)
delta_w9<-abs(d$day9-d$end9)
delta_w10<-abs(d$day10-d$end10)
delta_automotive<-abs(d$automotive_day-d$automative_end)
delta_stationary<-abs(d$stationary_day-d$stationary_end)
delta_unknown<-abs(d$unknown_day-d$unknown_end)
delta_walking<-abs(d$walking_day-d$walking_end)
delta_cycling<-abs(d$cycling_day-d$cycling_end)
delta_running<-abs(d$running_day-d$running_end)
delta_num_datapoints<-abs(d$num_datapoints_day-d$num_datapoints_end)
delta_mean_interval<-abs(d$mean_interval_day-d$mean_interval_end)
deltas<-data.frame(delta_w1,delta_w2,delta_w3,delta_w4,delta_w5,delta_w6,delta_w7,delta_w8,delta_w9,delta_w10,delta_automotive,delta_stationary,delta_unknown,delta_walking,delta_cycling,delta_running,delta_num_datapoints,delta_mean_interval,row.names=row.names(d)) 

deltas_wavelets<-deltas[,1:10] 
deltas_proportions<-deltas[,11:length(names(deltas))]


######DO CLUSTERING!!##################
#scaled_d=scale(d) 
#hc.d=hclust(dist(scaled_d),method="complete")
#png('hierarch_all.png') 
#plot(hc.d,main="Hierarchical Clust, Complete Link, All Features",labels=FALSE) 
#rect.hclust(hc.d,k=10)
#dev.off()
#save(hc.d,file="object_hc.d")


scaled_delta=scale(deltas) 
hc.delta=hclust(dist(scaled_delta),method="complete")
save(hc.delta,file="object_hc.delta")
png('hierarch_delta_all.png') 
plot(hc.delta,main="Hierarchical Clust, Complete Link, Delta Weekend vs Weekday",labels=FALSE) 
rect.hclust(hc.delta,k=10)
dev.off()

