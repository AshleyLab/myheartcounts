rm(list=ls())
library(data.table)
data=data.frame(read.table("fractions.updated.txt",header=T,sep='\t'))
data2=data.frame(read.table("NonTimeSeries.txt",header=T,sep='\t'))
data3=merge(data,data2,by="Subject")
data_men=data[which(data3$Sex %in% "Male"),]
data_women=data[which(data3$Sex %in% "Female"),]
mean(data_men$walkingFractionRecorded)
sd(data_men$walkingFractionRecorded)
mean(data_women$walkingFractionRecorded)
sd(data_women$walkingFractionRecorded)
age_20=data3[which(data3$Age <30),]
mean_20=mean(age_20$walkingFractionRecorded)
sd_20=sd(age_20$walkingFractionRecorded)

age_30=data3[which(data3$Age >=30 & data3$Age <40),]
mean_30=mean(age_30$walkingFractionRecorded)
sd_30=sd(age_30$walkingFractionRecorded)

age_40=data3[which(data3$Age >=40 & data3$Age <50),]
mean_40=mean(age_40$walkingFractionRecorded)
sd_40=sd(age_40$walkingFractionRecorded)

age_50=data3[which(data3$Age >=50 & data3$Age <60),]
mean_50=mean(age_50$walkingFractionRecorded)
sd_50=sd(age_50$walkingFractionRecorded)

age_60=data3[which(data3$Age >=60 & data3$Age <70),]
mean_60=mean(age_60$walkingFractionRecorded)
sd_60=sd(age_60$walkingFractionRecorded)

age_70=data3[which(data3$Age >=70),]
mean_70=mean(age_70$walkingFractionRecorded)
sd_70=sd(age_70$walkingFractionRecorded)

