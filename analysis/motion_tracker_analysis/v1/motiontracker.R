#for histogram of number of entries 
#x<-as.matrix(read.table('motiontracker_lengths.txt',header=FALSE))
#pdf('motionTracker_histogram.pdf') 
#hist(x,breaks=100,xlab="Number of MotionTracker Data Points (~30 second int.)",ylab="Number of Subje#cts")
#lines(c(2880,2880),c(0,2500),col='red') 
#lines(c(20160,20160),c(0,2500),col='red')
#text(2000,2500,'1 day') 
#text(25160,2500,'7 days') 
#dev.off() 

require(ggplot2) 
require(reshape2) 
df$time<-as.POSIXct(
