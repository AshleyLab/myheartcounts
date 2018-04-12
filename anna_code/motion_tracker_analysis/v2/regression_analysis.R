rm(list=ls())
motion_tracker=data.frame(read.table("~/sherlock/data/timeseries_v2/summary/motion_tracker_combined.filtered.txt.regression",header=TRUE,sep='\t',stringsAsFactors = FALSE))
healthkit_steps=data.frame(read.table("~/sherlock/data/timeseries_v2/summary/healthkit_combined.stepcount.txt.regression",header=TRUE,sep='\t',stringsAsFactors = FALSE))
healthkit_distance=data.frame(read.table("~/sherlock/data/timeseries_v2/summary/healthkit_combined.distance.txt.regression",header=TRUE,sep='\t',stringsAsFactors = FALSE))

#get subsets of the data frame of interest! 
stationary_subset=motion_tracker[motion_tracker$Activity=="stationary",]
walking_subset=motion_tracker[motion_tracker$Activity=="walking",]
active_subset=motion_tracker[motion_tracker$Activity %in% c("running","walking","cycling"),]
automotive_subset=motion_tracker[motion_tracker$Activity=="automotive",]
exercise_subset=motion_tracker[motion_tracker$Activity %in% c("running","cycling"),]

#run multivariate regression 

#steps 
healthkit_steps=healthkit_steps[healthkit_steps$Value<20000,]
healthkit_steps$Intervention=factor(healthkit_steps$Intervention,levels=c("Baseline","APHClusterModule","APHReadAHAWebsiteModule","APHStandModule","APHWalkModule","InterventionGap","PostIntervention"))
healthkit_steps$WatchVsPhone=factor(healthkit_steps$WatchVsPhone)
hk_step_fit=lm(Value~Intervention+dayIndex+Intervention*dayIndex+WatchVsPhone,data=healthkit_steps)

#steps for watch only 
healthkit_steps_watch=healthkit_steps[healthkit_steps$WatchVsPhone=="watch",]
healthkit_steps_watch$Intervention=factor(healthkit_steps_watch$Intervention,levels=c("Baseline","APHClusterModule","APHReadAHAWebsiteModule","APHStandModule","APHWalkModule","InterventionGap","PostIntervention"))
healthkit_steps_watch$WatchVsPhone=NULL
hk_step_watch_fit=lm(Value~Intervention+dayIndex+Intervention*dayIndex,data=healthkit_steps_watch)

#steps for phone only 
healthkit_steps_phone=healthkit_steps[healthkit_steps$WatchVsPhone=="phone",]
healthkit_steps_phone$Intervention=factor(healthkit_steps_phone$Intervention,levels=c("Baseline","APHClusterModule","APHReadAHAWebsiteModule","APHStandModule","APHWalkModule","InterventionGap","PostIntervention"))
healthkit_steps_phone$WatchVsPhone=NULL
hk_step_phone_fit=lm(Value~Intervention+dayIndex+Intervention*dayIndex,data=healthkit_steps_phone)


#distance 
healthkit_distance=healthkit_distance[healthkit_distance$Value<25000,]
healthkit_distance$Intervention=factor(healthkit_distance$Intervention,levels=c("Baseline","APHClusterModule","APHReadAHAWebsiteModule","APHStandModule","APHWalkModule","InterventionGap","PostIntervention"))
healthkit_distance$WatchVsPhone=factor(healthkit_distance$WatchVsPhone)
hk_distance_fit=lm(Value~Intervention+dayIndex+Intervention*dayIndex+WatchVsPhone,data=healthkit_distance)

#distance for watch only 
healthkit_distance_watch=healthkit_distance[healthkit_distance$WatchVsPhone=="watch",]
healthkit_distance_watch$Intervention=factor(healthkit_distance_watch$Intervention,levels=c("Baseline","APHClusterModule","APHReadAHAWebsiteModule","APHStandModule","APHWalkModule","InterventionGap","PostIntervention"))
healthkit_distance_watch$WatchVsPhone=NULL
hk_distance_watch_fit=lm(Value~Intervention+dayIndex+Intervention*dayIndex,data=healthkit_distance_watch)

#distance for phone only 
healthkit_distance_phone=healthkit_distance[healthkit_distance$WatchVsPhone=="phone",]
healthkit_distance_phone$Intervention=factor(healthkit_distance_phone$Intervention,levels=c("Baseline","APHClusterModule","APHReadAHAWebsiteModule","APHStandModule","APHWalkModule","InterventionGap","PostIntervention"))
healthkit_distance_phone$WatchVsPhone=NULL
hk_distance_phone_fit=lm(Value~Intervention+dayIndex+Intervention*dayIndex,data=healthkit_distance_phone)


#scatter plot of dayIndex vs Steps / Distance 
source('helpers.R')
p1=ggplot(data=healthkit_steps,aes(x=dayIndex,y=Value,group=Intervention,color=Intervention))+geom_point(alpha=0.5)+xlab("Day Index")+ ylab("HealthKit Steps")+ylim(c(0,20000))+ggtitle("Steps Phone+Watch")+ theme(legend.position="none")

p2=ggplot(data=healthkit_steps_watch,aes(x=dayIndex,y=Value,group=Intervention,color=Intervention))+geom_point(alpha=0.5)+xlab("Day Index")+ ylab("HealthKit Steps")+ylim(c(0,20000))+ggtitle("Steps Watch")+ theme(legend.position="none")

p3=ggplot(data=healthkit_steps_phone,aes(x=dayIndex,y=Value,group=Intervention,color=Intervention))+geom_point(alpha=0.5)+xlab("Day Index")+ ylab("HealthKit Steps")+ylim(c(0,20000))+ggtitle("Steps Phone")+ theme(legend.position="none")


p4=ggplot(data=healthkit_distance,aes(x=dayIndex,y=Value,group=Intervention,color=Intervention))+geom_point(alpha=0.5)+xlab("Day Index")+ ylab("HealthKit Distance(m)")+ylim(c(0,20000))+ggtitle("Distance Phone+Watch")+ theme(legend.position="none")

p5=ggplot(data=healthkit_distance_watch,aes(x=dayIndex,y=Value,group=Intervention,color=Intervention))+geom_point(alpha=0.5)+xlab("Day Index")+ ylab("HealthKit Distance(m)")+ylim(c(0,20000))+ggtitle("Distance Watch")+ theme(legend.position="none")

p6=ggplot(data=healthkit_distance_phone,aes(x=dayIndex,y=Value,group=Intervention,color=Intervention))+geom_point(alpha=0.5)+xlab("Day Index")+ ylab("HealthKit Distance(m)")+ylim(c(0,20000))+ggtitle("Distance Phone")+ theme(legend.position="none")


multiplot(p1,p4,p2,p5,p3,p6,cols=3)

#boxplot of Steps & Distance vs Intervention 
p7=ggplot(data=healthkit_steps,aes(x=Intervention,y=Value))+geom_boxplot()+xlab("Intervention")+ ylab("HealthKit Steps")+ylim(c(0,20000))+ggtitle("Steps Phone+Watch")+  theme(axis.text.x = element_text(angle = 90, hjust = 1))

p8=ggplot(data=healthkit_steps_watch,aes(x=Intervention,y=Value))+geom_boxplot()+xlab("Intervention")+ ylab("HealthKit Steps")+ylim(c(0,20000))+ggtitle("Steps Watch")+  theme(axis.text.x = element_text(angle = 90, hjust = 1))

p9=ggplot(data=healthkit_steps_phone,aes(x=Intervention,y=Value))+geom_boxplot()+xlab("Intervention")+ ylab("HealthKit Steps")+ylim(c(0,20000))+ggtitle("Steps Phone")+  theme(axis.text.x = element_text(angle = 90, hjust = 1))


p10=ggplot(data=healthkit_distance,aes(x=Intervention,y=Value))+geom_boxplot()+xlab("Intervention")+ ylab("HealthKit Distance(m)")+ylim(c(0,25000))+ggtitle("Distance Phone+Watch")+  theme(axis.text.x = element_text(angle = 90, hjust = 1))

p11=ggplot(data=healthkit_distance_watch,aes(x=Intervention,y=Value))+geom_boxplot()+xlab("Intervention")+ ylab("HealthKit Distance(m)")+ylim(c(0,25000))+ggtitle("Distance Watch")+  theme(axis.text.x = element_text(angle = 90, hjust = 1))

p12=ggplot(data=healthkit_distance_phone,aes(x=Intervention,y=Value))+geom_boxplot()+xlab("Intervention")+ ylab("HealthKit Distance(m)")+ylim(c(0,25000))+ggtitle("Distance Phone")+  theme(axis.text.x = element_text(angle = 90, hjust = 1))

multiplot(p7,p10,p8,p11,p9,p12,cols=3)


