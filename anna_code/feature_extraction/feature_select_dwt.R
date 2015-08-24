rm(list=ls())
library(data.table)
load("motion_tracker_concatenated")
#CBIND THE DATA FRAMES INTO A SINGLE FRAME FOR PCA AND CLUSTERING ! 

#SEPARATE ANALYSIS FOR EACH LEVEL OF THE DWT 
#WEEKDAY
nlevels<-length(full_weekday_dwt)
for(i in 1:nlevels)
{
  cur_data<-full_weekday_dwt[[i]]
  if(i==1)
  {
    cur_data$var_EDR_d=NULL
  }
  nr=nrow(cur_data)
  pc=prcomp(cur_data,scale=TRUE)
  par(mfrow=c(2,2))
  png(paste("weekday","dwt","l",i,".png",sep="_"))
  biplot(pc,choices=c(1,2),scale=0,xlabs=rep(".",nr),main=paste("Level",i,sep=" "))
  biplot(pc,choices=c(2,3),scale=0,xlabs=rep(".",nr),main=paste("Level",i,sep=" "))
  biplot(pc,choices=c(1,3),scale=0,xlabs=rep(".",nr))
  pr.var=pc$sdev^2
  pve=pr.var/sum(pr.var)
  plot(cumsum(pve),xlab="Prin Comp",ylab="Proportion of variance explained",ylim=c(0,1),type="b")
  #browser() 
  dev.off() 
}

#WEEKDAY
nlevels<-length(full_weekend_dwt)
for(i in 1:nlevels)
{
  cur_data<-full_weekend_dwt[[i]]
  if(i==1)
  {
    cur_data$var_EDR_d=NULL
  }
  nr=nrow(cur_data)
  pc=prcomp(cur_data,scale=TRUE)
  par(mfrow=c(2,2))
  png(paste("weekend","dwt","l",i,".png",sep="_"))
  biplot(pc,choices=c(1,2),scale=0,xlabs=rep(".",nr),main=paste("Level",i,sep=" "))
  biplot(pc,choices=c(2,3),scale=0,xlabs=rep(".",nr),main=paste("Level",i,sep=" "))
  biplot(pc,choices=c(1,3),scale=0,xlabs=rep(".",nr))
  pr.var=pc$sdev^2
  pve=pr.var/sum(pr.var)
  plot(cumsum(pve),xlab="Prin Comp",ylab="Proportion of variance explained",ylim=c(0,1),type="b")
  #browser() 
  dev.off() 
}