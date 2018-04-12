rm(list=ls())
motion_tracker=data.frame(read.table("~/sherlock/data/timeseries_v2/summary/motion_tracker_combined.filtered.txt.regression",header=TRUE,sep='\t'))
healthkit_steps=data.frame(read.table("~/sherlock/data/timeseries_v2/summary/healthkit_combined.stepcount.txt.regression",header=TRUE,sep='\t'))
healthkit_distance=data.frame(read.table("~/sherlock/data/timeseries_v2/summary/healthkit_combined.distance.txt.regression",header=TRUE,sep='\t'))

#get subsets of the data frame of interest! 
stationary_subset=motion_tracker[motion_tracker$Activity=="stationary",]
walking_subset=motion_tracker[motion_tracker$Activity=="walking",]
active_subset=motion_tracker[motion_tracker$Activity %in% c("running","walking","cycling"),]
automotive_subset=motion_tracker[motion_tracker$Activity=="automotive",]
exercise_subset=motion_tracker[motion_tracker$Activity %in% c("running","cycling"),]

library(ggplot2)
#stationary fractions
stationary_plot_fractions=ggplot(stationary_subset,aes(stationary_subset$Intervention,stationary_subset$Fraction))+
  geom_boxplot() + 
  ylim(c(0,1))+
  xlab("Intervention")+
  ylab("Fraction of Activity Spent in Stationary State")+
  ggtitle("Stationary Fractions")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

png("stationary_plot_fractions.png")
print(stationary_plot_fractions)
dev.off() 

aov_stationary_fractions<-aov(Fraction~Intervention,data=stationary_subset)
capture.output(summary(aov_stationary_fractions), file = "stationary_fractions.aov.txt")
tk_stationary_fractions<-TukeyHSD(aov_stationary_fractions,conf.level=0.95)
capture.output(tk_stationary_fractions, file = "stationary_fractions.tukey.txt")

#stationary duration 
stationary_subset=stationary_subset[stationary_subset$Duration_in_Minutes <=1440,]
stationary_plot_duration=ggplot(stationary_subset,aes(stationary_subset$Intervention,stationary_subset$Duration_in_Minutes))+
  geom_boxplot() + 
  ylim(c(0,1440))+
  xlab("Intervention")+
  ylab("Minutes/Day Spent in Stationary State")+
  ggtitle("Stationary Minutes/Day")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

png("stationary_plot_duration.png")
print(stationary_plot_duration)
dev.off() 
aov_stationary_duration<-aov(Duration_in_Minutes~Intervention,data=stationary_subset)
capture.output(summary(aov_stationary_duration), file = "stationary_duration.aov.txt")
tk_stationary_duration<-TukeyHSD(aov_stationary_duration,conf.level=0.95)
capture.output(tk_stationary_duration, file = "stationary_duration.tukey.txt")

#automotive fractions
automotive_plot_fractions=ggplot(automotive_subset,aes(automotive_subset$Intervention,automotive_subset$Fraction))+
  geom_boxplot() + 
  ylim(c(0,1))+
  xlab("Intervention")+
  ylab("Fraction of Activity Spent in automotive State")+
  ggtitle("automotive Fractions")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

png("automotive_plot_fractions.png")
print(automotive_plot_fractions)
dev.off() 
aov_automotive_fractions<-aov(Fraction~Intervention,data=automotive_subset)
capture.output(summary(aov_automotive_fractions), file = "automotive_fractions.aov.txt")
tk_automotive_fractions<-TukeyHSD(aov_automotive_fractions,conf.level=0.95)
capture.output(tk_automotive_fractions, file = "automotive_fractions.tukey.txt")

#automotive duration
#automotive_subset=automotive_subset[automotive_subset$Duration_in_Minutes<120,]
automotive_plot_duration=ggplot(automotive_subset,aes(automotive_subset$Intervention,automotive_subset$Duration_in_Minutes))+
  geom_boxplot() + 
  xlab("Intervention")+
  ylab("Minutes/Day Spent in automotive State")+
  ggtitle("automotive Minutes/Day")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

png("automotive_plot_duration.png")
print(automotive_plot_duration)
dev.off() 
aov_automotive_duration<-aov(Duration_in_Minutes~Intervention,data=automotive_subset)
capture.output(summary(aov_automotive_duration), file = "automotive_duration.aov.txt")
tk_automotive_duration<-TukeyHSD(aov_automotive_duration,conf.level=0.95)
capture.output(tk_automotive_duration, file = "automotive_duration.tukey.txt")


#active fractions
active_plot_fractions=ggplot(active_subset,aes(active_subset$Intervention,active_subset$Fraction))+
  geom_boxplot() + 
  ylim(c(0,1))+
  xlab("Intervention")+
  ylab("Fraction of Activity Spent in active State")+
  ggtitle("Active Fraction")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

png("active_plot_fractions.png")
print(active_plot_fractions)
dev.off() 
aov_active_fractions<-aov(Fraction~Intervention,data=active_subset)
capture.output(summary(aov_active_fractions), file = "active_fractions.aov.txt")
tk_active_fractions<-TukeyHSD(aov_active_fractions,conf.level=0.95)
capture.output(tk_active_fractions, file = "active_fractions.tukey.txt")

#active duration 
#active_subset=active_subset[active_subset$Duration_in_Minutes<=200,]
active_plot_duration=ggplot(active_subset,aes(active_subset$Intervention,active_subset$Duration_in_Minutes))+
  geom_boxplot() + 
  xlab("Intervention")+
  ylab("Minutes/Day Spent in active State")+
  ggtitle("Active Minutes/Day")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

png("active_plot_duration.png")
print(active_plot_duration)
dev.off() 
aov_active_duration<-aov(Duration_in_Minutes~Intervention,data=active_subset)
capture.output(summary(aov_active_duration), file = "active_duration.aov.txt")
tk_active_duration<-TukeyHSD(aov_active_duration,conf.level=0.95)
capture.output(tk_active_duration, file = "active_duration.tukey.txt")


#walking fraction 
walking_plot_fractions=ggplot(walking_subset,aes(walking_subset$Intervention,walking_subset$Fraction))+
  geom_boxplot() + 
  ylim(c(0,1))+
  xlab("Intervention")+
  ylab("Fraction of Activity Spent in Walking State")+
  ggtitle("Walking Fraction")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

png("walking_plot_fractions.png")
print(walking_plot_fractions)
dev.off() 
aov_walking_fractions<-aov(Fraction~Intervention,data=walking_subset)
capture.output(summary(aov_walking_fractions), file = "walking_fractions.aov.txt")
tk_walking_fractions<-TukeyHSD(aov_walking_fractions,conf.level=0.95)
capture.output(tk_walking_fractions, file = "walking_fractions.tukey.txt")

#walking duration 
#walking_subset=walking_subset[walking_subset$Duration_in_Minutes<=300,]
walking_plot_duration=ggplot(walking_subset,aes(walking_subset$Intervention,walking_subset$Duration_in_Minutes))+
  geom_boxplot() + 
  xlab("Intervention")+
  ylab("Minutes/Day Spent in Walking State")+
  ggtitle("Walking Minutes/Day")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
png("walking_plot_duration.png")
print(walking_plot_duration)
dev.off() 
aov_walking_duration<-aov(Duration_in_Minutes~Intervention,data=walking_subset)
capture.output(summary(aov_walking_duration), file = "walking_duration.aov.txt")
tk_walking_duration<-TukeyHSD(aov_walking_duration,conf.level=0.95)
capture.output(tk_walking_duration, file = "walking_duration.tukey.txt")

#running/cycling fraction 
exercise_plot_fractions=ggplot(exercise_subset,aes(exercise_subset$Intervention,exercise_subset$Fraction))+
  geom_boxplot() + 
  xlab("Intervention")+
  ylab("Fraction of Activity Spent in Running/Cycling State")+
  ggtitle("Running/Cycling Fraction")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
png("exercise_plot_fractions.png")
print(exercise_plot_fractions)
dev.off() 
aov_exercise_fractions<-aov(Fraction~Intervention,data=exercise_subset)
capture.output(summary(aov_exercise_fractions), file = "exercise_fractions.aov.txt")
tk_exercise_fractions<-TukeyHSD(aov_exercise_fractions,conf.level=0.95)
capture.output(tk_exercise_fractions, file = "exercise_fractions.tukey.txt")

#exercise duration 
#exercise_subset=exercise_subset[exercise_subset$Duration_in_Minutes<=50,]
exercise_plot_duration=ggplot(exercise_subset,aes(exercise_subset$Intervention,exercise_subset$Duration_in_Minutes))+
  geom_boxplot() + 
  xlab("Intervention")+
  ylab("Minutes/Day Spent in Running/Cycling State")+
  ggtitle("Running/Cycling Minutes/Day")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

png("exercise_plot_duration.png")
print(exercise_plot_duration)
dev.off() 
aov_exercise_duration<-aov(Duration_in_Minutes~Intervention,data=exercise_subset)
capture.output(summary(aov_exercise_duration), file = "exercise_duration.aov.txt")
tk_exercise_duration<-TukeyHSD(aov_exercise_duration,conf.level=0.95)
capture.output(tk_exercise_duration, file = "exercise_duration.tukey.txt")

#step count 
healthkit_steps=healthkit_steps[healthkit_steps$Value<=20000,]
steps_plot=ggplot(healthkit_steps,aes(healthkit_steps$Intervention,healthkit_steps$Value))+
  geom_boxplot() + 
  xlab("Intervention")+
  ylab("HealthKit Daily Steps")+
  ggtitle("HealthKit Daily Steps")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

png("steps_plot.png")
print(steps_plot)
dev.off() 
aov_steps<-aov(Value~Intervention,data=healthkit_steps)
capture.output(summary(aov_steps), file = "steps.aov.txt")
tk_steps<-TukeyHSD(aov_steps,conf.level=0.95)
capture.output(tk_steps, file = "steps.tukey.txt")

#distance traveled 
healthkit_distance=healthkit_steps[healthkit_distance$Value<=25000,]
distance_plot=ggplot(healthkit_distance,aes(healthkit_distance$Intervention,healthkit_distance$Value))+
  geom_boxplot() + 
  xlab("Intervention")+
  ylab("HealthKit Daily distance(m)")+
  ggtitle("HealthKit Daily Distance(m)")+
  theme_bw(20)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

png("distance_plot.png")
print(distance_plot)
dev.off() 
aov_distance<-aov(Value~Intervention,data=healthkit_distance)
capture.output(summary(aov_distance), file = "distance.aov.txt")
tk_distance<-TukeyHSD(aov_distance,conf.level=0.95)
capture.output(tk_distance, file = "distance.tukey.txt")
