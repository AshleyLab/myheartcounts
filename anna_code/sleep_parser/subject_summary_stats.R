rm(list=ls())
library(ggplot2)

data=read.table("sleep_data_summary.subjects.txt",header=TRUE,sep='\t')
data$sleep_hours=data$MeanSleepDuration/3600
data[data$sleep_hours>24,]=NA
ggplot(data=data,
       aes(x=data$sleep_hours))+
  geom_histogram()+
  xlab("Mean Hours Slept")+
  ylab("Number of Subjects")+
  ggtitle("Mean Sleep Duration=5.38 hours")