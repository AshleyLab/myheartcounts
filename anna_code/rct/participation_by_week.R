rm(list=ls())
library(ggplot2)
source("~/helpers.R")

data=read.table("participation_by_week.csv",header=TRUE,sep='\t')
p1=ggplot(data=data,
       aes(x=data$Week,
           y=data$ParticipantDays,
           group=data$Intervention,
           color=data$Intervention))+
  geom_line()+
  geom_point()+
  xlab("Week of Study")+
  ylab("User-Days")+
  scale_color_manual(values=c('#1b9e77','#d95f02','#7570b3','#e7298a'),name="Intervention")+
  theme_bw(20)
p2=ggplot(data=data,
          aes(x=data$Week,
              y=data$Participants,
              group=data$Intervention,
              color=data$Intervention))+
  geom_line()+
  geom_point()+
  xlab("Week of Study")+
  ylab("Users")+
  scale_color_manual(values=c('#1b9e77','#d95f02','#7570b3','#e7298a'),name="Intervention")+
  theme_bw(20)
multiplot(p1,p2,cols=2)