rm(list=ls()) 
#LOAD THE HIERARCHICAL AND K-MEANS CLUSTERING OBJECTS 
load("object_hc.d") 
load("object_hc.delta") 
load("object_km.d") 
load("object_km.delta") 

d<-as.data.frame(read.table("motiontracker_data.txt",row.name=1,header=T)) 

#CUT H-CLUST TREES TO 10 CLASSES 
#hc.d.10<-cutree(hc.d,10) 
#hc.delta.10<-cutree(hc.delta,10) 


#LOAD THE CATEGORICAL DATA 
metadata_file<-'Non_timeseries_filtered.tsv'
meta<-read.table(metadata_file,sep="\t",header=TRUE,row.names=1)
meta<-as.data.frame(meta)

#merged_h<-merge(hc.d.10,meta,by="row.names",all.x=TRUE)
#rownames(merged_h)=merged_h$Row.names 

 merged_k<-merge(km.d$cluster,meta,by="row.names",all.x=TRUE) 
 rownames(merged_k)=merged_k$Row.names 
 merged_k$clusters<-factor(merged_k$x) 
 attach(merged_k) 
 km.d.aov<-aov(feel_worthwhile2~clusters,data=merged_k) 
 capture.output(summary(km.d.aov), file = "km.d.aov.happy.txt")

png('kmeans_vs_feelhappy.png') 
plot(feel_worthwhile2~clusters,data=merged_k,main="K-Means Motion Clusters vs Feel Happy")
means <- aggregate(feel_worthwhile2 ~  clusters, merged_k, mean)
points(means,col="red")

dev.off() 

aov.pair<-pairwise.t.test(feel_worthwhile2,clusters,p.adjust="bonferroni") 
capture.output(aov.pair, file = "km.d.happy.aov.pair.txt")

tk<-TukeyHSD(km.d.aov,conf.level=0.95)
capture.output(tk, file = "km.d.happy.tukey.txt")

 
#PLOT MEAN ACTIVITY DISTRIBUTION FOR EACH CLUSTER 
#counter=seq(1,10,by=1)
#for(i in counter)
#{
#n<-names(which(km.d$cluster==i))
#numentries<-length(n) 
#di<-d[which(rownames(d) %in% n),]
#di.walking.day<-mean(di$walking_day)
#di.walking.end<-mean(di$walking_end) 
#di.cycling.day<-mean(di$cycling_day)
#di.cycling.end<-mean(di$cycling_end) 
#di.stationary.day<-mean(di$stationary_day)
#di.stationary.end<-mean(di$stationary_end) 
#di.running.day<-mean(di$running_day)
#di.running.end<-mean(di$running_end) 
#di.automotive.day<-mean(di$automotive_day)
#di.automotive.end<-mean(di$automative_end) 
#plottitle=paste("cluster_plot",i,".png",sep="")
#main_title=paste("Cluster ",i,", ",numentries," Weekday",sep="") 
#png(plottitle)
#par(mfrow=c(2,1)) 
#barplot(c(di.stationary.day,di.automotive.day,di.walking.day,di.cycling.day,di.running.day),names.arg=c("Stationary","Automotive","Walking","Cycling","Running"),main=main_title,ylim=c(0,0.5),ylab="Proportion of Activity")
#main_title=paste("Cluster ",i,", ",numentries," Weekend",sep="") 
#barplot(c(di.stationary.end,di.automotive.end,di.walking.end,di.cycling.end,di.running.end),names.arg=c("Stationary","Automotive","Walking","Cycling","Running"),main=main_title,ylim=c(0,0.5),ylab="Proportion of Activity")
#dev.off() 
#}

#delta_w1<-(d$day1-d$end1)
#delta_w2<-(d$day2-d$end2)
#delta_w3<-(d$day3-d$end3) 
#delta_w4<-(d$day4-d$end4) 
#delta_w5<-(d$day5-d$end5) 
#delta_w10<-(d$day10-d$end10)
#delta_w7<-(d$day7-d$end7)
#delta_w8<-(d$day8-d$end8)
#delta_w9<-(d$day9-d$end9)
#delta_w10<-(d$day10-d$end10)
#delta_automotive<-(d$automotive_day-d$automative_end)
#delta_stationary<-(d$stationary_day-d$stationary_end)
#delta_unknown<-(d$unknown_day-d$unknown_end)
#delta_walking<-(d$walking_day-d$walking_end)
#delta_cycling<-(d$cycling_day-d$cycling_end)
#delta_running<-(d$running_day-d$running_end)
#delta_num_datapoints<-(d$num_datapoints_day-d$num_datapoints_end)
#delta_mean_interval<-abs(d$mean_interval_day-d$mean_interval_end)
#deltas<-data.frame(delta_w1,delta_w2,delta_w3,delta_w4,delta_w5,delta_w10,delta_w7,delta_w8,delta_w9,delta_w10,delta_automotive,delta_stationary,delta_unknown,delta_walking,delta_cycling,delta_running,delta_num_datapoints,delta_mean_interval,row.names=row.names(d)) 

#ANOVA FOR KM_DELTA
merged_k<-merge(km.delta$cluster,meta,by="row.names",all.x=TRUE) 
rownames(merged_k)=merged_k$Row.names 
merged_k$clusters<-factor(merged_k$x) 
detach(merged_k) 
attach(merged_k) 
km.d.aov<-aov(feel_worthwhile2~clusters,data=merged_k) 
capture.output(summary(km.d.aov), file = "km.delta.happy.aov.txt")

png('kmeans_vs_happy_delta.png') 
plot(feel_worthwhile2~clusters,data=merged_k,main="K-Means Motion Clusters (Delta Weekend vs Weekday) vs Feel Happy")
means <- aggregate(feel_worthwhile2 ~  clusters, merged_k, mean)
points(means,col="red")

dev.off() 

aov.pair<-pairwise.t.test(feel_worthwhile2,clusters,p.adjust="bonferroni") 
capture.output(aov.pair, file = "km.delta.happy.aov.pair.txt")

tk<-TukeyHSD(km.d.aov,conf.level=0.95)
capture.output(tk, file = "km.delta.happy.tukey.txt")

##PLOT CLUSTERS FOR KM DELTA 
#counter=seq(1,10,by=1)
#for(i in counter)
#{
#n<-names(which(km.delta$cluster==i))
#numentries=length(n) 
#di<-deltas[which(rownames(d) %in% n),]
#di.walking<-mean(di$delta_walking)
#di.cycling<-mean(di$delta_cycling)
#di.automotive<-mean(di$delta_automotive)
#di.running<-mean(di$delta_running)
#di.stationary<-mean(di$delta_stationary)
#par(mfrow=c(1,1))
#plottitle=paste("cluster_plot_deltas",i,".png",sep="")
#main_title=paste("Cluster ",i,", ",numentries, " Subjects" ,sep="") 
#png(plottitle) 
#barplot(c(di.stationary,di.automotive,di.walking,di.cycling,di.running),names.arg=c("Stationary","Automotive","Walking","Cycling","Running"),main=main_title,ylim=c(-.10,0.10),ylab="Proportion of Activity, Weekday - Weekend")
#dev.off() 
#}
