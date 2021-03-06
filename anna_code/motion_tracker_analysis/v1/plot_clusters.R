rm(list=ls()) 
#LOAD THE HIERARCHICAL AND K-MEANS CLUSTERING OBJECTS 
load("object_km.d") 
load("object_km.delta") 
d<-as.data.frame(read.table("motiontracker_data.txt",row.name=1,header=T)) 


#LOAD THE CATEGORICAL DATA 
metadata_file<-'Non_timeseries_filtered.tsv'
meta<-read.table(metadata_file,sep="\t",header=TRUE,row.names=1)
meta<-as.data.frame(meta)

merged_k<-merge(km.d$cluster,meta,by="row.names",all.x=TRUE) 
rownames(merged_k)=merged_k$Row.names 
merged_k$clusters<-factor(merged_k$x) 
attach(merged_k) 

 
#PLOT ACTIVITY DISTRIBUTION FOR EACH CLUSTER 
counter=seq(1,10,by=1)
for(i in counter)
{
n<-names(which(km.d$cluster==i))
numentries<-length(n) 
di<-d[which(rownames(d) %in% n),]
di.walking.day<-(di$walking_day)
di.walking.end<-(di$walking_end) 
di.cycling.day<-(di$cycling_day)
di.cycling.end<-(di$cycling_end) 
di.stationary.day<-(di$stationary_day)
di.stationary.end<-(di$stationary_end) 
di.running.day<-(di$running_day)
di.running.end<-(di$running_end) 
di.automotive.day<-(di$automotive_day)
di.automotive.end<-(di$automative_end) 

#di.numdatapoints.day<-di$num_datapoints_day/10000
#di.numdatapoints.end<-di$num_datapoints_end/10000
#di.mean_interval.day<-di$mean_interval_day/1000
#di.mean_interval.end<-di$mean_interval_end/1000

plottitle=paste("cluster_plot",i,".png",sep="")
main_title=paste("Cluster ",i,", ",numentries,sep="") 
png(plottitle)
par(mfrow=c(1,1))
par(mar=c(6, 4, 4, 2) + 0.7)
boxplot(di.stationary.day, di.stationary.end, di.automotive.day,di.automotive.end, di.walking.day,di.walking.end, di.cycling.day,di.cycling.end, di.running.day,di.running.end, names=c("Stationary WD","Stationary WE","Automotive WD","Automotive WE", "Walking WD", "Waking WE", "Cycling WD", "Cycling WE", "Running WD", "Running WE"),main=main_title,las=2,ylab="Proportion of Activity",ylim=c(0,0.5))
points(1:10, c(mean(di.stationary.day),mean(di.stationary.end),mean(di.automotive.day),mean(di.automotive.end),mean(di.walking.day),mean(di.automotive.end),mean(di.cycling.day),mean(di.cycling.end),mean(di.running.day), mean(di.running.end)),col="red")
dev.off() 
}
