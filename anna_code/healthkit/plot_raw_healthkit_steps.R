rm(list=ls())
library(ggplot2)
library(reshape2)
library(lubridate)
source('helpers.R')

#subject="0a3a8074-130f-4eae-8ee6-98485df94b58"
#subject="1aaec753-1685-490c-9468-62c886ab3cae"
#subject="2a0701f9-1f25-477f-abec-9ed4c55e9ec8"
#subject="e8ead3c7-055e-4a5e-b08d-9043918ceb09"
subject="ec6c54ff-68e9-4086-bfc4-f98e9eb3ab80"
#read in the motion tracker and healthkit data for the specified subject 
mt=read.table(paste(subject,"MotionTracker.txt",sep='.'),header=TRUE,sep='\t',stringsAsFactors = FALSE)
hk=read.table(paste(subject,"HealthKitDataCollector.txt",sep='.'),header=TRUE,sep='\t',stringsAsFactors = FALSE)

#convert the timestamps from characters into POSIXct objects 
hk$startTime=strptime(hk$startTime,"%Y-%m-%dT%H:%M:%S")
hk$endTime=strptime(hk$endTime,"%Y-%m-%dT%H:%M:%S")
mt$startTime=strptime(mt$startTime,"%Y-%m-%dT%H:%M:%S")

steps=hk[hk$type=="HKQuantityTypeIdentifierStepCount",]
steps=data.frame(rowsum(steps$value,format(steps$startTime,"%Y-%m-%d")))
steps$date=as.POSIXct(strptime(rownames(steps),"%Y-%m-%d"))
names(steps)=c("steps","date")

distance=hk[hk$type=="HKQuantityTypeIdentifierDistanceWalkingRunning",]
distance=data.frame(rowsum(distance$value,format(distance$startTime,"%Y-%m-%d")))
distance$date=as.POSIXct(strptime(rownames(distance),"%Y-%m-%d"))
names(distance)=c("distance","date")

hk=merge(steps,distance,by="date")
hk=hk[2:nrow(hk),]
hk=melt(hk,id="date")

p1=ggplot(hk,aes(x=date,y=value,group=variable,color=variable))+
  geom_line()+
  geom_point()+
  ggtitle(subject)+
  theme_bw(20)

#versus activity fractions 
data_dir="~/sherlock/data/timeseries_v2/summary"
motion_df=read.table(paste(data_dir,"motion_tracker_combined.txt",sep='/'),header=TRUE,sep='\t',stringsAsFactors = FALSE)
motion_subset=subset(motion_df,select=c("Subject","DayIndex","Activity","Fraction"))
fract=motion_subset[motion_subset$Subject==subject,] 

fract$DayIndex=date(ddays(fract$DayIndex)+min(min(hk$date)))
p2=ggplot(fract,aes(x=DayIndex,y=Fraction,group=Activity,color=Activity))+
  geom_line()+
  geom_point()+
  theme_bw(20)


fract_sub=subset(fract,select=c("DayIndex","Activity","Fraction"))
names(fract_sub)=c("date","variable","value")
fract_sub=fract_sub[fract_sub$variable=="walking",]
fract_sub$value=fract_sub$value*20000
alldata=rbind(fract_sub,hk)
p3=ggplot(data=alldata,aes(x=date,y=value,group=variable,color=variable))+
  geom_line()+
  geom_point()+ 
  theme_bw(20)

multiplot(p1,p2,p3,cols=1)
