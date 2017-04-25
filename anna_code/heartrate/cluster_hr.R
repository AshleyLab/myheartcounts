library(ggplot2)
library(reshape2)
rm(list=ls())
load('hr_rest.bin')
load('hr_walk.bin')

#par(mfrow=c(2,5))
#hist(hr_walk$z1,xlab="Proportion of time spent in Zone 1",ylab="Number of Subjects",main="Walking, Zone1")
#hist(hr_walk$z2,xlab="Proportion of time spent in Zone 2",ylab="Number of Subjects",main="Walking, Zone2")
#hist(hr_walk$z3,xlab="Proportion of time spent in Zone 3",ylab="Number of Subjects",main="Walking, Zone3")
#hist(hr_walk$z4,xlab="Proportion of time spent in Zone 4",ylab="Number of Subjects",main="Walking, Zone4")
#hist(hr_walk$z5,xlab="Proportion of time spent in Zone 5",ylab="Number of Subjects",main="Walking, Zone5")

#hist(hr_rest$z1,xlab="Proportion of time spent in Zone 1",ylab="Number of Subjects",main="Resting, Zone1")
#hist(hr_rest$z2,xlab="Proportion of time spent in Zone 1",ylab="Number of Subjects",main="Resting, Zone2")
#hist(hr_rest$z3,xlab="Proportion of time spent in Zone 1",ylab="Number of Subjects",main="Resting, Zone3")
#hist(hr_rest$z4,xlab="Proportion of time spent in Zone 1",ylab="Number of Subjects",main="Resting, Zone4")
#hist(hr_rest$z5,xlab="Proportion of time spent in Zone 1",ylab="Number of Subjects",main="Resting, Zone5")

#K-Means clustering on the walk HR data 

#K-Means clustering on the rest HR data

#K-Means clustering on the matched data 

#include zones 

#include recovery rate 

#overlay on activity clsuters 


hr_rest$subject=rownames(hr_rest)
hr_walk$subject=rownames(hr_walk)


hrr=melt(hr_rest,id.vars="subject")
hrw=melt(hr_walk,id.vars="subject")
hrr_index=which(hrr$variable %in% c("zlow","z1","z2","z3","z4","z5","zhigh"))
hrw_index=which(hrw$variable %in% c("zlow","z1","z2","z3","z4","z5","zhigh"))
hrr_z=na.omit(hrr[hrr_index,])
hrw_z=na.omit(hrw[hrw_index,])

hrr_z=hrr_z[order(hrr_z$value, hrr_z$variable),]
hrw_z=hrw_z[order(hrw_z$value, hrw_z$variable),]

ggplot(hrr_z,aes(x=subject,y=value,fill=variable))+geom_bar(stat="identity")
ggplot(hrw_z,aes(x=subject,y=value,fill=variable))+geom_bar(stat="identity")

par(mfrow=c(2,1))
hr_rest=hr_rest[order(hr_rest$Mean,hr_rest$Min,hr_rest$Max),]
hr_walk=hr_walk[order(hr_walk$Mean,hr_walk$Min,hr_walk$Max),]
plot(hr_walk$Mean,type='l',ylab="Heart Rate (bpm)",xlab="subject",main="Walk")
lines(hr_walk$Min,col="blue")
lines(hr_walk$Max,col="red")

plot(hr_rest$Mean,type='l',ylab="Heart Rate (bpm)",xlab="subject",main="Rest")
lines(hr_rest$Min,col="blue")
lines(hr_rest$Max,col="red")

par(mfrow=c(1,1))
hist(hr_rest$recovery,xlab="-1*Delta bpm in first minute of rest",ylab="Number of subjects",main="Recovery heart rate")