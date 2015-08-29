library(ggplot2)
data<-data.frame(read.table("/home/anna/scg2/grouped_timeseries/motiontracker_sampled/weekend/91dcb176-cacb-48f4-9581-88caaa572f90.tsv",header=F))
p<-ggplot(data, aes(x=c(1:nrow(data)), V3),ylab="Activity State")
p + geom_point(aes(fill="blue"),alpha = 1/5,pch=22,color="black")+ xlab("Time") +
  ylab("Activity State") +
  theme(axis.text.x=element_text(colour="black"))+
  theme(axis.text.y=element_text(colour="black"))

