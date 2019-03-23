rm(list=ls())
source("../helpers.R")
library(parsedate)
library(scales)
library(ggplot2)
mt.date=read.table("v2.motion.hist.by_date.tsv",header=TRUE,sep='\t')
mt.date=mt.date[order(mt.date$Date),]
mt.date$Date=as.Date(mt.date$Date)

mt.subject=read.table("v2.motion.hist.by_subject.tsv",header=TRUE,sep='\t')
mt.subject=mt.subject[order(mt.subject$NumDaysData),]
p1=ggplot(data=mt.subject,
          aes(x=mt.subject$NumDaysData,
              y=mt.subject$NumSubjects))+
  geom_histogram(stat="identity")+
  geom_line(aes(x=mt.subject$NumDaysData,y=3567-cumsum(mt.subject$NumSubjects)))+
  xlab("Number of Days Core Motion Data")+
  ylab("Number of Subjects")+
  xlim(0,35)

p2=ggplot(data=mt.date,
          aes(x=mt.date$Date,
              y=mt.date$NumSubjects))+
  geom_histogram(stat="identity")+
  xlab("Date")+
  ylab("Number of Subjects with Core Motion Data")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") 

hk.date=read.table("v2.hk.hist.by_date.tsv",header=TRUE,sep='\t')
hk.date=hk.date[order(hk.date$Date),]
hk.date$Date=as.Date(hk.date$Date)

hk.subject=read.table("v2.hk.hist.by_subject.tsv",header=TRUE,sep='\t')
hk.subject=hk.subject[order(hk.subject$NumDaysData),]
p3=ggplot(data=hk.subject,
          aes(x=hk.subject$NumDaysData,
              y=hk.subject$NumSubjects))+
  geom_histogram(stat="identity")+
  geom_line(aes(x=hk.subject$NumDaysData,y=4578-cumsum(hk.subject$NumSubjects)))+
  xlab("Number of Days HealthKit Data")+
  ylab("Number of Subjects")+
  xlim(0,35)

p4=ggplot(data=hk.date,
          aes(x=hk.date$Date,
              y=hk.date$NumSubjects))+
  geom_histogram(stat="identity")+
  xlab("Date")+
  ylab("Number of Subjects with HealthKit Data")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") 

test.date=read.table("v2.6mwt.hist.by_date.tsv",header=TRUE,sep='\t')
test.date=test.date[order(test.date$Date),]
test.date$Date=as.Date(test.date$Date)

test.subject=read.table("v2.6mwt.hist.by_subject.tsv",header=TRUE,sep='\t')
test.subject=test.subject[order(test.subject$NumDaysData),]
p5=ggplot(data=test.subject,
          aes(x=test.subject$NumDaysData,
              y=test.subject$NumSubjects))+
  geom_histogram(stat="identity")+
  xlab("Number of Days with 6MWT Data")+
  ylab("Number of Subjects")+
  xlim(0,35)

p6=ggplot(data=test.date,
          aes(x=test.date$Date,
              y=test.date$NumSubjects))+
  geom_histogram(stat="identity")+
  xlab("Date")+
  ylab("Number of Subjects with 6MWT Data")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  scale_x_date(date_breaks = "1 month", date_labels =  "%b %Y") 




multiplot(p1,p2,p3,p4,cols=2)