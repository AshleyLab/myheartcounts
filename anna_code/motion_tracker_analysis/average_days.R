rm(list=ls())
library(data.table)
library(ggplot2)
data=data.frame(read.table("alldays",header=F))

# More complex
m <- ggplot(data, aes(x=V1))+geom_histogram() +xlab("Days with Activity Data")+ylab("Number of Subjects")+xlim(c(0,75))+theme_bw(20)

hours=data.frame(read.table("allhours",header=F))
m <- ggplot(hours, aes(x=as.numeric(V1)),bindwidth=1)+geom_histogram() +xlab("Hours/Day with Activity Data")+ylab("Number of Days")+theme_bw(20)+xlim(c(0,24))+stat_bin(binwidth=1,dropt=TRUE)
