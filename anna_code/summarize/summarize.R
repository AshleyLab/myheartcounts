rm(list=ls())
library(data.table)
library(ggplot2)
setwd("/home/anna/scg/myheartcounts/anna_code/summarize/")
#load("6minwalk_feature_selection_results.bin")
#walk_clust<-as.data.frame(best_fit$cluster)
#setnames(walk_clust,"best_fit$cluster","walk_cluster")
#load('motion_tracker_feature_selection_results.bin')

load("full_activ.bin")
load("full_6min.bin")
activ_clust<-as.data.frame(cl$cluster)
walk_clust<-as.data.frame(cl_6min$cluster)
setnames(activ_clust,"cl$cluster","activ_cluster")
setnames(walk_clust,"cl_6min$cluster","walk_cluster")
nt<-data.frame(read.table("NonTimeSeries.txt",header=T,sep="\t",row.names=1))
ha<-data.frame(read.table("HeartAgeRelatedPredictions.txt",header=T,sep="\t",row.names=1))
#walk_merged=merge(nt,walk_clust,by="row.names",all=TRUE)
#walk_merged=merge(walk_merged,ha,by="row.names",all=TRUE)
#walk_merged=merge(walk_merged,activ_clust,by="row.names",all=TRUE)

#FOR ACTIVITY STATE ANALYSIS! 
activ_merged<-merge(activ_clust,ha,by="row.names",all=T)
rownames(activ_merged)=activ_merged$Row.names
activ_merged$Row.names=NULL 
subjects<-rownames(activ_merged)
nt_sub=nt[subjects,]
nt_sub$activ_cluster=activ_merged$activ_cluster
nt_sub$X10YearRisk=activ_merged$X10YearRisk
nt_sub$LifetimeRisk95=activ_merged$LifetimeRisk95
nt_sub$HeartAge=activ_merged$HeartAge
nt_sub$BMI=activ_merged$BMI
save(nt_sub,file="merged_activ.bin")

#FOR 6MINUTE WALK ANALYSIS! 
walk_merged<-merge(walk_clust,ha,by="row.names",all=T)
rownames(walk_merged)=walk_merged$Row.names
walk_merged$Row.names=NULL 
subjects<-rownames(walk_merged)
nt_walk=nt[subjects,]
browser() 
nt_walk$walk_cluster=walk_merged$walk_cluster

nt_walk$X10YearRisk=walk_merged$X10YearRisk
nt_walk$LifetimeRisk95=walk_merged$LifetimeRisk95
nt_walk$HeartAge=walk_merged$HeartAge
nt_walk$BMI=walk_merged$BMI
save(nt_walk,file="merged_walk.bin")

#PLOTS! 
#VS AGE 
#par(mfrow=c(2,2))
bwplot(LifetimeRisk95~ clusters, data=m,horizontal=FALSE,xlab=list(label="Activity Cluster", fontsize=20),ylab=list(label="Lifetime Risk",fontsize=20),col="blue",
      par.settings = list( box.umbrella=list(col= "blue"), 
                            box.dot=list(col= "blue"), 
                            box.rectangle = list(col=  "blue")),scales=list(cex=1.5))
# 
# 
# bwplot(HeartAge ~ activ_cluster, data=nt_sub,horizontal=FALSE,ylim=c(1,91),xlab="Activity Cluster",ylab="Subject Heart Age",col="blue",
#        par.settings = list( box.umbrella=list(col= "blue"), 
#                             box.dot=list(col= "blue"), 
#                             box.rectangle = list(col=  "blue") 
#        )           )
# 
# 
bwplot(BMI ~ walk_cluster, data=nt_walk,horizontal=FALSE,ylim=c(1,91),xlab=list(label="6 Minute Walk Cluster",fontsize=20),ylab=list(label="BMI",fontsize=20),col="blue",
        par.settings = list( box.umbrella=list(col= "blue"), 
                             box.dot=list(col= "blue"), 
                             box.rectangle = list(col=  "blue")),scales=list(cex=1.5))
 
# bwplot(LifetimeRisk95 ~ walk_cluster, data=nt_walk,horizontal=FALSE,xlab="6 Minute Walk Cluster",ylab="Subject Lifetime Risk",col="blue",
#        par.settings = list( box.umbrella=list(col= "blue"), 
#                             box.dot=list(col= "blue"), 
#                             box.rectangle = list(col=  "blue") 
#        )           )

#VS SEX 
#VS RISK 
#VS HEART AGE 

