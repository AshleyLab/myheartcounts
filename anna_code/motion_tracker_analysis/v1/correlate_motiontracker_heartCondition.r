rm(list=ls()) 
#LOAD THE HIERARCHICAL AND K-MEANS CLUSTERING OBJECTS 
#load("object_hc.d") 
#load("object_hc.delta") 
load("object_km.d") 
load("object_km.delta") 

d<-as.data.frame(read.table("motiontracker_data.txt",row.name=1,header=T)) 


#LOAD THE CATEGORICAL DATA 
metadata_file<-'Non_timeseries_filtered.tsv'
meta<-read.table(metadata_file,sep="\t",header=TRUE,row.names=1)
meta<-as.data.frame(meta)

#merged_h<-merge(hc.d.10,meta,by="row.names",all.x=TRUE)
#rownames(merged_h)=merged_h$Row.names 

merged_k<-merge(km.d$cluster,meta,by="row.names",all.x=TRUE) 
rownames(merged_k)=merged_k$Row.names 
merged_k$clusters<-factor(merged_k$x)
browser() 
attach(merged_k)
png("kmeans_vs_heartCondition.png") 
plot(table(merged_k$clusters,merged_k$heartCondition),xlab="Cluster",ylab="Relative Proportion of TRUE to FALSE", main="Heart Condition vs Activity Cluster" )
dev.off()

capture.output(chisq.test(merged_k$clusters,merged_k$heartCondition),file="chisquare_heart_condition.txt")

#ANOVA FOR KM_DELTA
merged_k<-merge(km.delta$cluster,meta,by="row.names",all.x=TRUE) 
rownames(merged_k)=merged_k$Row.names 
merged_k$clusters<-factor(merged_k$x) 
detach(merged_k) 
attach(merged_k)

png("kmeans_delta_vs_heartCondition.png") 
plot(table(merged_k$clusters,merged_k$heartCondition),xlab="Cluster",ylab="Relative Proportion of TRUE to FALSE", main="Heart Condition vs Activity Cluster" )
dev.off()
capture.output(chisq.test(merged_k$clusters,merged_k$heartCondition),file="chisquare_delta_heart_condition.txt")
