rm(list=ls())
library(data.table)
data<-as.data.frame(read.table("fractions_v2.txt",header=T,sep='\t')) 
data$unknownWeekend=NULL 
data$unknownWeekday=NULL 
km.d=kmeans(data,7,nstart=50) 
#save(km.d,file="kmeans_v2.Rdata")
########################################
data$cluster=km.d$cluster
####rank subjects by activity level##### 
data$fractionActive=data$runningWeekday+data$runningWeekend+data$walkingWeekday+data$walkingWeekend+data$cyclingWeekday+data$cyclingWeekend
data=data[with(data, order(-fractionActive)), ]
data$Subject=row.names(data)
data$Ranks=1:nrow(data)
#merge with the other fields 
other=data.frame(read.table("DataFreezeDataFrame_10022015.txt",header=T,sep='\t'))
merged=merge(other,data,by="Subject",all.x=TRUE)
merged$fractionActive=NULL 
#write.csv(merged,file="DataFreezeDataFrame_10022015_VERSION2.txt")

#visualize the clusters and compare to old labels. 
#PLOT ACTIVITY DISTRIBUTION FOR EACH CLUSTER 
counter=seq(1,7,by=1)
for(i in counter)
{

  di=data[which(data$cluster %in% i),];
  numentries=nrow(di)
  plottitle=paste("cluster_plot_whatif",i,".png",sep="")
  main_title=paste("Cluster ",i,", ",numentries,sep="") 
  png(plottitle)
  par(mfrow=c(1,1))
  par(mar=c(6, 4, 4, 2) + 0.7)
  boxplot(di$stationaryWeekday, di$stationaryWeekend, di$automotiveWeekday,di$automotiveWeekend, di$walkingWeekday,di$walkingWeekend, di$cyclingWeekday,di$cyclingWeekend, di$runningWeekday,di$runningWeekend, names=c("Stationary WD","Stationary WE","Automotive WD","Automotive WE", "Walking WD", "Waking WE", "Cycling WD", "Cycling WE", "Running WD", "Running WE"),main=main_title,las=2,ylab="Proportion of Activity",ylim=c(0,1))
  points(1:10, c(mean(di$stationaryWeekday),mean(di$stationaryWeekend),mean(di$automotiveWeekday),mean(di$automotiveWeekend),mean(di$walkingWeekday),mean(di$automotiveWeekend),mean(di$cyclingWeekday),mean(di$cyclingWeekend),mean(di$runningWeekday), mean(di$runningWeekend)),col="red")
  dev.off() 
}
