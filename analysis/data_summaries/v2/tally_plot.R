rm(list=ls())
library(ggplot2)
data=data.frame(read.table("tally_interventions.txt",header=TRUE,sep='\t'))
data$MinDaysWithData=factor(data$MinDaysWithData)
ggplot(data,aes(x=data$Intervention,
                y=data$MotionTrackerSubjects,
                group=data$MinDaysWithData,
                fill=data$MinDaysWithData))+
  geom_bar(stat="identity",
           position="dodge")+
  xlab("Intervention")+
  ylab("Number of Subjects")+
  ggtitle("MHC 2.0 Motion Tracker\n Num Subjects for Each Intervention")+
  theme_bw(20)


ggplot(data,aes(x=data$Intervention,
                y=data$MotionTrackerSubjects,
                group=data$MinDaysWithData,
                fill=data$MinDaysWithData))+
  geom_bar(stat="identity",
           position="dodge")+
  xlab("Intervention")+
  ylab("Number of Subjects")+
  ggtitle("MHC 2.0 Motion Tracker\n Num Subjects for Each Intervention")+
  theme_bw(20)


ggplot(data,aes(x=data$Intervention,
                y=data$HealthKitStepSubjects,
                group=data$MinDaysWithData,
                fill=data$MinDaysWithData))+
  geom_bar(stat="identity",
           position="dodge")+
  xlab("Intervention")+
  ylab("Number of Subjects")+
  ggtitle("MHC 2.0 HealthKit Step Count\n Num Subjects for Each Intervention")+
  theme_bw(20)

ggplot(data,aes(x=data$Intervention,
                y=data$HealthKitDistanceSubjects,
                group=data$MinDaysWithData,
                fill=data$MinDaysWithData))+
  geom_bar(stat="identity",
           position="dodge")+
  xlab("Intervention")+
  ylab("Number of Subjects")+
  ggtitle("MHC 2.0 HealthKit Distance\n Num Subjects for Each Intervention")+
  theme_bw(20)
