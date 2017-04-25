library(wavelets) 
library(data.table)
library(ggplot2)
source('helpers.R')
ss<-function(x)
{
  sum(x^2)
}

#magic numbers
changepoint_thresh<-10
n_levels<-10
min_valid_duration<-355 #subject must have 6 minutes +/- 5 seconds of data to be used in the analysis 
max_valid_duration<-365 
min_valid_rest_duration<-180
max_valid_rest_duration<-365 

#directories with acceleration data
accel_walk_dir<-'/home/anna/6minute_walk_small/acceleration_walk'
accel_rest_dir<-'/home/anna/6minute_walk_small/acceleration_rest'

#age, sex, other categorical information 
metadata_file<-'/home/anna/ashleylab_git/myhealthapp/Non_timeseries_data_07012014.tsv'
#meta=data.table(fread(metadata_file),row.names=1)
#browser() 
#Pedometer for QC 
#pedometer_dir<-'/home/anna/6minute_walk/pedometer'
#############################################################################################

#############################################################################################
#extract features for acceleration walk
subjects<-c("005a2b21-b3b8-4538-9919-c4cff8736281.tsv","005eb8bc-2f61-4fea-83e6-db7e83e819b2.tsv","0070f2fc-4738-4e45-b0f6-53acd6479ace.tsv","00966cb0-0cc9-4217-bc9b-bbb7e46a9d1f.tsv",
"005c1f6b-2650-4e85-8004-b55bec38ac13.tsv","0069d5dc-d39c-4cb5-a9c4-3375d95e7458.tsv","007a138c-d99b-4b44-8aa8-e8da0465b534.tsv",
"005e0beb-dd33-4e0a-a7b7-1b1f7e50749f.tsv","006bd5d3-b8cc-490b-a316-226617956d0b.tsv","00815e64-ca0a-46dd-ada2-c91d6fbfb25a.tsv")
for(c in 1:length(subjects))
{
  subject=subjects[c]
  fname_walk=paste('/home/anna/6minute_walk_small/acceleration_walk/',subject,sep="")
  fname_rest=paste('/home/anna/6minute_walk_small/acceleration_rest/',subject,sep="")
  x_walk=fread(fname_walk,header=T)
  x_rest=fread(fname_rest,header=T)
  par(mfrow=c(2,3))
  #CHECK FOR THE CHANGEPOINTS 
  delta<-diff(x_walk$timestamp)
  changepoints<-which(delta %in% subset(delta,abs(delta)>changepoint_thresh))
  changepoints<-c(0,changepoints,length(x_walk$timestamp))
  for (j in 1:(length(changepoints)-1))
  {cur_segment=x_walk[changepoints[j]:changepoints[j+1],]
  #MAKE SURE THERE ARE 6 MINUTES OF DATA 
  duration<-cur_segment$timestamp[length(cur_segment$timestamp)] - cur_segment$timestamp[1]
  print(duration)
  if ((duration > min_valid_duration) && (duration < max_valid_duration))
  {
    segsmall=cur_segment[18000:18500,]
    p1<-ggplot(segsmall, aes(timestamp, x)) + 
      geom_line(size=2)+
      xlab("\nTime (ms)") +
      ylab("Acceleration(M/s^2)\n") +
      ggtitle("a")+
      theme_bw(20)+
      theme(plot.title=element_text(hjust=0))
    tran=dwt(segsmall$x,n.levels = 8)
    par(mfrow=c(1,1))
    plot.dwt(tran, levels = list(c(1,2,3,4),c(1,2,3,4)), plot.X=FALSE,draw.boundary = TRUE,col.boundary = "blue",lwd=2,main="b",xlab="Time(ms)")
    #multiplot(p1,plot.dwt(tran, levels = list(c(1,2,3,4),c(1,2,3,4)), plot.X=FALSE,draw.boundary = TRUE,col.boundary = "blue",main="b")
    #,col=2)
    browser() 

    
    plot(cur_segment$timestamp,cur_segment$x,main="Acceleration Walk X")
    plot(cur_segment$timestamp,cur_segment$y,main="Acceleration Walk Y")
    plot(cur_segment$timestamp,cur_segment$z,main="Acceleration Walk Z")
    break 
  }
  }
  
  #REST DATA 
  #CHECK FOR THE CHANGEPOINTS 
  delta<-diff(x_rest$timestamp)
  changepoints<-which(delta %in% subset(delta,abs(delta)>changepoint_thresh))
  changepoints<-c(0,changepoints,length(x_rest$timestamp))
  for (j in 1:(length(changepoints)-1))
  {cur_segment=x_rest[changepoints[j]:changepoints[j+1],]
  #MAKE SURE THERE ARE 6 MINUTES OF DATA 
  duration<-cur_segment$timestamp[length(cur_segment$timestamp)] - cur_segment$timestamp[1]
  print(duration)
  if ((duration > min_valid_rest_duration) && (duration < max_valid_rest_duration))
  {
    plot(cur_segment$timestamp,cur_segment$x,main="Acceleration Rest X")
    plot(cur_segment$timestamp,cur_segment$y,main="Acceleration Rest Y")
    plot(cur_segment$timestamp,cur_segment$z,main="Acceleration Rest Z")
    break 
  }
  }
}