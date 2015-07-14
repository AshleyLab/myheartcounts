rm(list=ls())
library(data.table)
#ALL FEATURES 
#PCA 
d<-as.data.frame(read.table("motiontracker_data.txt",row.name=1,header=T)) 
browser() 

wavelets<-d[,1:20] 
proportions<-d[,21:32]

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

#mydata <- proportions
#wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var))
#  for (i in 2:40) wss[i] <- sum(kmeans(mydata,centers=i)$withinss)
#png('best_k.png') 
#plot(1:40, wss, type="b", xlab="Number of Clusters",
#     ylab="Within groups sum of squares")
#dev.off() 

#browser() 
library(fpc)
library(cluster) 
asw <- numeric(20)
for (k in 2:20)
{
print(k) 
asw[[k]] <- pam(proportions, k) $ silinfo $ avg.width
}
k.best <- which.max(asw)
cat("silhouette-optimal number of clusters:", k.best, "\n")


######DO CLUSTERING!!##################
km.d=kmeans(proportions,10,nstart=50) 
save(km.d,file="testobject_km.d")
km.delta=kmeans(deltas_proportions,10,nstart=50) 
save(km.delta,file="testobject_km.delta") 
