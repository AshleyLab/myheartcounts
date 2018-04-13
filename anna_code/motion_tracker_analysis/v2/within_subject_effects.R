rm(list=ls())
data=read.table("within_subject_measures.txt",header=TRUE,sep='\t')
steps=data[data$Measure=="HKQuantityTypeIdentifierStepCount",]
distance=data[data$Measure=="HKQuantityTypeIdentifierDistanceWalk",]

steps$Computation=NULL
steps$Measure=NULL 
steps$Intervention=factor(steps$Intervention,levels=c("Baseline",
                                                      "APHClusterModule",
                                                      "APHReadAHAWebsiteModule",
                                                      "APHStandModule",
                                                      "APHWalkModule",
                                                      "InterventionGap",
                                                      "PostIntervention"))

distance$Computation=NULL 
distance$Measure=NULL
distance$Intervention=factor(distance$Intervention,levels=c("Baseline",
                                                      "APHClusterModule",
                                                      "APHReadAHAWebsiteModule",
                                                      "APHStandModule",
                                                      "APHWalkModule",
                                                      "InterventionGap",
                                                      "PostIntervention"))
library(nlme)
model=lme(Value~Intervention,random=~1|Subject,data=steps,method="REML")
library(car)

