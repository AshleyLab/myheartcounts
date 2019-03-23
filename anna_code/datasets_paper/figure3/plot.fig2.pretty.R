rm(list=ls())
library(ggplot2)
library(reshape2)

#data_subject=read.table("merged.by_subject.txt",header=TRUE,sep='\t')
#data_date=read.table("merged.by_date.txt",header=TRUE,sep='\t')
#survey data 
data_subject=read.table("merged.surveys.by_subject.txt",header=TRUE,sep='\t')
data_date=read.table("merged.surveys.by_date.txt",header=TRUE,sep='\t')

data_date=data_date[order(data_date$NumDays),]
data_date$Date=as.Date(data_date$NumDays)
data_date$NumDays=NULL

msubject=melt(data_subject,id="NumDays")
mdate=melt(data_date,id="Date")

p1=ggplot(data=msubject,
       aes(x=NumDays,
           y=value,
           group=variable,
           fill=variable))+
  geom_histogram(stat="identity",position="dodge")+
  scale_fill_manual(values=c('#1b9e77','#d95f02','#7570b3','#e7298a','#66a61e','#e6ab02','#a6761d','#666666'),
                    name="Data Type",
                    labels=c("ActivitySleep", "Day1","LifeSatisfaction", "Diet","PARQ","DailyCheck","HeartAge","RiskFactors"))+
  xlim(0,25)+
  ylim(0,10000)+
  xlab("Days In Study")+
  ylab("Number of Participants")+
  theme_bw()+
  scale_y_log10()

source("~/helpers.R")
#p2=ggplot(data=mdate,
#       aes(x=Date,
#           y=value,
#           group=variable,
#           fill=variable))+
#  geom_histogram(stat="identity",position="dodge")+
#  scale_fill_manual(values=c('#1b9e77','#d95f02','#7570b3','#e7298a'),
#                    name="Data Type",
#                    labels=c("Core Motion", "HealthKit","6-Minute Walk Test","Survey Responses"))+
#  xlab("Days In Study")+
#  ylab("Number of Participants")+
#  theme_bw()+
#  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
#  scale_x_date(date_breaks = "1 week", date_labels =  "%b %Y") 

p3=ggplot(data=mdate,
          aes(x=Date,
              y=value,
              group=variable,
              color=variable))+
  geom_point()+
  geom_line()+
  scale_color_manual(values=c('#1b9e77','#d95f02','#7570b3','#e7298a','#66a61e','#e6ab02','#a6761d','#666666'),
                    name="Data Type",
                    labels=c("ActivitySleep", "Day1","LifeSatisfaction", "Diet","PARQ","DailyCheck","HeartAge","RiskFactors"))+
  xlab("Days In Study")+
  ylab("Number of Participants")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  scale_x_date(date_breaks = "1 week", date_labels =  "%b %Y") +
  scale_y_log10()


multiplot(p1,p3,cols=1)
