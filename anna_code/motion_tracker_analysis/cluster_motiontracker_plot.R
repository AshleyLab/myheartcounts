rm(list=ls())

library(wavelets) 
library(data.table)

ss<-function(x)
{
  sum(x^2)
}
basedir='/home/anna/scg3_common/'
#basedir='/home/annashch/myheart/myheart/'
long_weekday<-as.data.frame(read.table(paste(basedir,'grouped_timeseries/motiontracker_sampled/weekday/72098ea9-44cc-42f3-8a1a-27fbaaf499b9.tsv',sep=''),stringsAsFactors=FALSE))
long_weekend<-as.data.frame(read.table(paste(basedir,'grouped_timeseries/motiontracker_sampled/weekend/72098ea9-44cc-42f3-8a1a-27fbaaf499b9.tsv',sep=''),stringsAsFactors=FALSE))
short_weekend<-as.data.frame(read.table(paste(basedir,'grouped_timeseries/motiontracker_sampled/weekend/9984b8d2-36b3-4e89-b83a-2fb2feaf7bd6.tsv',sep=''),stringsAsFactors=FALSE))
short_weekday<-as.data.frame(read.table(paste(basedir,'grouped_timeseries/motiontracker_sampled/weekday/9984b8d2-36b3-4e89-b83a-2fb2feaf7bd6.tsv',sep=''),stringsAsFactors=FALSE))
long_weekend$V1 <- strptime(long_weekend$V1,"%Y-%m-%dT%H:%M:%S")
short_weekend$V1 <- strptime(short_weekend$V1,"%Y-%m-%dT%H:%M:%S")
long_weekday$V1 <- strptime(long_weekday$V1,"%Y-%m-%dT%H:%M:%S")
short_weekday$V1 <- strptime(short_weekday$V1,"%Y-%m-%dT%H:%M:%S")

delta_longweekend<-as.numeric(diff(long_weekend$V1))
delta_longweekday<-as.numeric(diff(long_weekday$V1))
delta_shortweekend<-as.numeric(diff(short_weekend$V1))
delta_shortweekday<-as.numeric(diff(short_weekday$V1))
png('sampling_granularity_long_short.png') 
par(mfrow=c(2,2))
hist(delta_longweekend[delta_longweekend<1000],500)
hist(delta_shortweekend[delta_shortweekend<1000],500)
hist(delta_longweekday[delta_longweekday<1000],500)
hist(delta_shortweekday[delta_shortweekday<1000],500)
dev.off()

png('hourly_long_short.png')
plot.new()
par(mfrow=c(2,2))
hist(hour(long_weekend$V1),24)
hist(hour(short_weekend$V1),24)
hist(hour(long_weekday$V1),24)
hist(hour(short_weekday$V1),24)
dev.off()

dwt_longweekend<-dwt(as.numeric(long_weekend$V3),n.level=10)
dwt_longweekday<-dwt(as.numeric(long_weekday$V3),n.level=10)
dwt_shortweekend<-dwt(as.numeric(short_weekend$V3),n.level=10)
dwt_shortweekday<-dwt(as.numeric(short_weekday$V3),n.level=10)
png('dwt_long_weekend.png')
plot.new() 
plot.dwt(dwt_longweekend,main='Long Weekend')
dev.off()

png('dwt_long_weekday.png')
plot.new() 
plot.dwt(dwt_longweekday,main='Long Weekday')
dev.off()


png('dwt_short_weekend.png')
plot.new() 
plot.dwt(dwt_shortweekend,main='Short Weekend')
dev.off()

png('dwt_short_weekday.png')
plot.new() 
plot.dwt(dwt_shortweekday,main='Short Weekday')
dev.off()

long_weekend$V2<-factor(long_weekend$V2)
long_weekday$V2<-factor(long_weekday$V2)
short_weekend$V2<-factor(short_weekend$V2)
short_weekday$V2<-factor(short_weekday$V2)
png('activity_proportions.png')
plot.new()
par(mfrow=c(2,2))
hist(as.numeric(long_weekend$V2),breaks=levels(long_weekend$V3),labels=levels(long_weekend$V2),main="Weekend,Long")
hist(as.numeric(short_weekend$V2),breaks=c(0,1,2,3,4,5,6),labels=levels(short_weekend$V2),main="Weekend,Short")
hist(as.numeric(long_weekday$V2),breaks=c(0,1,2,3,4,5,6),labels=levels(long_weekday$V2),main="Weekday,Long")
hist(as.numeric(short_weekday$V2),breaks=c(0,1,2,3,4,5,6),labels=levels(short_weekday$V2),main="Weekday,Short")
dev.off()

