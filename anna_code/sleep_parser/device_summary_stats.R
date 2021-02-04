rm(list=ls())
library(ggplot2)
#counts 
device_summary=read.table("sleep_data_summary.devices.txt",header=TRUE,sep='\t')
app_summary=read.table("sleep_data_summary.apps.txt",header=TRUE,sep='\t')
device_summary$Device=factor(device_summary$Device,levels=device_summary$Device)
app_summary$App=factor(app_summary$App,levels=app_summary$App)

#data=read.table("out.HKCategoryValueSleepAnalysisAsleep",header=TRUE,sep='\t')
p1=ggplot(data=device_summary,aes(x=device_summary$Device,y=device_summary$Individuals))+
  geom_bar(stat='identity')+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  xlab("Device")+
  ylab("Individuals")

p2=ggplot(data=device_summary,aes(x=device_summary$Device,y=device_summary$PersonDays))+
  geom_bar(stat='identity')+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  xlab("Device")+
  ylab("PersonDays")


p3=ggplot(data=app_summary,aes(x=app_summary$App,y=app_summary$Individuals))+
  geom_bar(stat='identity')+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  xlab("App")+
  ylab("Individuals")

p4=ggplot(data=app_summary,aes(x=app_summary$App,y=app_summary$PersonDays))+
  geom_bar(stat='identity')+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  xlab("App")+
  ylab("PersonDays")

source("~/helpers.R")
multiplot(p1,p2,p3,p4,cols=1)

