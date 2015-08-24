rm(list=ls())
library(data.table)
load("6minwalk_concatenated") 
#CBIND THE DATA FRAMES INTO A SINGLE FRAME FOR PCA AND CLUSTERING ! 

#SEPARATE ANALYSIS FOR EACH LEVEL OF THE DWT 
#REST
nlevels<-length(full_rest_result_dwt)
for(i in 1:nlevels)
{
  cur_data<-full_rest_result_dwt[[i]]
  if(i==1)
  {
    cur_data$var_EDR_d_x=NULL
    cur_data$var_EDR_d_y=NULL 
    cur_data$var_EDR_d_z=NULL
  }
  nr=nrow(cur_data)
  pc=prcomp(cur_data,scale=TRUE)
  png(paste("rest","dwt","l",i,".png",sep="_"))
  par(mfrow=c(2,2))
  
  #biplot(pc,choices=c(1,2),scale=0,xlabs=rep(".",nr),var.axes=TRUE,main=paste("Level",i,sep=" "))
  #biplot(pc,choices=c(2,3),scale=0,xlabs=rep(".",nr),var.axes=TRUE,main=paste("Level",i,sep=" "))
  #biplot(pc,choices=c(1,3),scale=0,xlabs=rep(".",nr),var.axes=TRUE)
  plot(pc$x[,1:2],main=paste("Level",i,sep=" "))
  plot(pc$x[,2:3],main=paste("Level",i,sep=" "))
  plot(pc$x[,c(1,3)])
  pr.var=pc$sdev^2
  pve=pr.var/sum(pr.var)
  plot(cumsum(pve),xlab="Prin Comp",ylab="Proportion of variance explained",ylim=c(0,1),type="b")
  browser() 
  dev.off() 
}

#WALK
nlevels<-length(full_walk_result_dwt)
for(i in 1:nlevels)
{
  cur_data<-full_walk_result_dwt[[i]]
  if(i==1)
  {
    cur_data$var_EDR_d_x=NULL
    cur_data$var_EDR_d_y=NULL 
    cur_data$var_EDR_d_z=NULL
    
  }
  nr=nrow(cur_data)
  pc=prcomp(cur_data,scale=TRUE)
  png(paste("walk","dwt","l",i,".png",sep="_"))
  par(mfrow=c(2,2))
  
  #biplot(pc,choices=c(1,2),scale=0,xlabs=rep(".",nr),main=paste("Level",i,sep=" "))
  #biplot(pc,choices=c(2,3),scale=0,xlabs=rep(".",nr),main=paste("Level",i,sep=" "))
  #biplot(pc,choices=c(1,3),scale=0,xlabs=rep(".",nr))
  plot(pc$x[,1:2],main=paste("Level",i,sep=" "))
  plot(pc$x[,2:3],main=paste("Level",i,sep=" "))
  plot(pc$x[,c(1,3)])
  pr.var=pc$sdev^2
  pve=pr.var/sum(pr.var)
  plot(cumsum(pve),xlab="Prin Comp",ylab="Proportion of variance explained",ylim=c(0,1),type="b")
  browser() 
  dev.off() 
}