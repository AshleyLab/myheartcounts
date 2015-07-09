#Rachel Goldfeder

#make table 2

# goal is to read in the data and get mean and SD for 
# 6MW, activity self reported data and, motion tracker data [active, stationary] 


all<- read.table("dsams_collapse_0414.tsv", header=T,as.is=T)
males<- all[all$gender=="[HKBiologicalSexMale]" & !is.na(all$gender),]
females<- all[all$gender=="[HKBiologicalSexFemale]" & !is.na(all$gender),]
age.lt.30<- all[all$age<30 & !is.na(all$age),]
age.30s<- all[all$age<40 & all$age>=30 & !is.na(all$age),]
age.40s<- all[all$age<50 & all$age>=40 & !is.na(all$age),]
age.50s<- all[all$age<60 & all$age>=50 & !is.na(all$age),]
age.60s<- all[all$age<70 & all$age>=60 & !is.na(all$age),]
age.gt.70<- all[all$age>=70 & !is.na(all$age),]

groups<-c("males", "females", "age.lt.30", "age.30s", "age.40s", "age.50s", "age.60s", "age.gt.70")
group.means=matrix(nrow=length(groups), ncol=2)
group.sds=matrix(nrow=length(groups), ncol=2)


#number of steps

mean(males$numberOfSteps, na.rm=T)
mean(females$numberOfSteps, na.rm=T)
mean(age.lt.30$numberOfSteps, na.rm=T)
mean(age.30s$numberOfSteps, na.rm=T)
mean(age.40s$numberOfSteps, na.rm=T)
mean(age.50s$numberOfSteps, na.rm=T)
mean(age.60s$numberOfSteps, na.rm=T)
mean(age.gt.70$numberOfSteps, na.rm=T)

sd(males$numberOfSteps, na.rm=T)
sd(females$numberOfSteps, na.rm=T)
sd(age.lt.30$numberOfSteps, na.rm=T)
sd(age.30s$numberOfSteps, na.rm=T)
sd(age.40s$numberOfSteps, na.rm=T)
sd(age.50s$numberOfSteps, na.rm=T)
sd(age.60s$numberOfSteps, na.rm=T)
sd(age.gt.70$numberOfSteps, na.rm=T)


#distance

mean(males$distance, na.rm=T)
mean(females$distance, na.rm=T)
mean(age.lt.30$distance, na.rm=T)
mean(age.30s$distance, na.rm=T)
mean(age.40s$distance, na.rm=T)
mean(age.50s$distance, na.rm=T)
mean(age.60s$distance, na.rm=T)
mean(age.gt.70$distance, na.rm=T)

sd(males$distance, na.rm=T)
sd(females$distance, na.rm=T)
sd(age.lt.30$distance, na.rm=T)
sd(age.30s$distance, na.rm=T)
sd(age.40s$distance, na.rm=T)
sd(age.50s$distance, na.rm=T)
sd(age.60s$distance, na.rm=T)
sd(age.gt.70$distance, na.rm=T)


#active

mean(males$pActive, na.rm=T)
mean(females$pActive, na.rm=T)
mean(age.lt.30$pActive, na.rm=T)
mean(age.30s$pActive, na.rm=T)
mean(age.40s$pActive, na.rm=T)
mean(age.50s$pActive, na.rm=T)
mean(age.60s$pActive, na.rm=T)
mean(age.gt.70$pActive, na.rm=T)

sd(males$pActive, na.rm=T)
sd(females$pActive, na.rm=T)
sd(age.lt.30$pActive, na.rm=T)
sd(age.30s$pActive, na.rm=T)
sd(age.40s$pActive, na.rm=T)
sd(age.50s$pActive, na.rm=T)
sd(age.60s$pActive, na.rm=T)
sd(age.gt.70$pActive, na.rm=T)




#active

mean(males$pActive, na.rm=T)
mean(females$pActive, na.rm=T)
mean(age.lt.30$pActive, na.rm=T)
mean(age.30s$pActive, na.rm=T)
mean(age.40s$pActive, na.rm=T)
mean(age.50s$pActive, na.rm=T)
mean(age.60s$pActive, na.rm=T)
mean(age.gt.70$pActive, na.rm=T)

sd(males$pActive, na.rm=T)
sd(females$pActive, na.rm=T)
sd(age.lt.30$pActive, na.rm=T)
sd(age.30s$pActive, na.rm=T)
sd(age.40s$pActive, na.rm=T)
sd(age.50s$pActive, na.rm=T)
sd(age.60s$pActive, na.rm=T)
sd(age.gt.70$pActive, na.rm=T)






#N's
summary(males$distance)
summary(males$sleep)
summary(males$pActive)
summary(females$distance)
summary(females$sleep)
summary(females$pActive)
summary(age.lt.30$distance)
summary(age.lt.30$sleep)
summary(age.lt.30$pActive)
summary(age.30s$distance)
summary(age.30s$sleep)
summary(age.30s$pActive)
summary(age.40s$distance)
summary(age.40s$sleep)
summary(age.40s$pActive)
summary(age.50s$distance)
summary(age.50s$sleep)
summary(age.50s$pActive)
summary(age.60s$distance)
summary(age.60s$sleep)
summary(age.60s$pActive)
summary(age.gt.70$distance)
summary(age.gt.70$sleep)
summary(age.gt.70$pActive)


all.plusSleep<-merge(all, sleep.table, by="healthCode", all.x=T)

#filter sleep
all.plusSleep$sleep_time[all.plusSleep$sleep_time > 15 | all.plusSleep$sleep_time < 1] = NA

#filter activity
#no minimum, just 0

all.plusSleep$moderate_act[all.plusSleep$moderate_act < 0] = NA
all.plusSleep$vigorous_act[all.plusSleep$vigorous_act < 0] = NA



#max is 8 hrs a day for 7 days
all.plusSleep$moderate_act[all.plusSleep$moderate_act > 3360] = NA
all.plusSleep$vigorous_act[all.plusSleep$vigorous_act > 3360] = NA




all.collapse = ddply(all.plusSleep, .(healthCode), summarize, mod.act =mean(moderate_act, na.rm=T),
                     vig.act =mean(vigorous_act, na.rm=T), sleep =mean(sleep_time, na.rm=T) , gender = gender[1], age = mean(age), 
                     numberOfSteps = mean(numberOfSteps, na.rm=T), distance = mean(distance, na.rm=T), pActive=mean(pActive))

all.collapse$total.act = all.collapse$vig.act + all.collapse$mod.act



males<- all.collapse[all.collapse$gender=="[HKBiologicalSexMale]" & !is.na(all.collapse$gender),]
females<- all.collapse[all.collapse$gender=="[HKBiologicalSexFemale]" & !is.na(all.collapse$gender),]
age.lt.30<- all.collapse[all.collapse$age<30 & !is.na(all.collapse$age),]
age.30s<- all.collapse[all.collapse$age<40 & all.collapse$age>=30 & !is.na(all.collapse$age),]
age.40s<- all.collapse[all.collapse$age<50 & all.collapse$age>=40 & !is.na(all.collapse$age),]
age.50s<- all.collapse[all.collapse$age<60 & all.collapse$age>=50 & !is.na(all.collapse$age),]
age.60s<- all.collapse[all.collapse$age<70 & all.collapse$age>=60 & !is.na(all.collapse$age),]
age.gt.70<- all.collapse[all.collapse$age>=70 & !is.na(all.collapse$age),]




summary(males$total.act)
summary(males$sleep)
summary(females$total.act)
summary(females$sleep)
summary(age.lt.30$total.act)
summary(age.lt.30$sleep)
summary(age.30s$total.act)
summary(age.30s$sleep)
summary(age.40s$total.act)
summary(age.40s$sleep)
summary(age.50s$total.act)
summary(age.50s$sleep)
summary(age.60s$total.act)
summary(age.60s$sleep)
summary(age.gt.70$total.act)
summary(age.gt.70$sleep)












mean(males$sleep, na.rm=T)
mean(females$sleep, na.rm=T)
mean(age.lt.30$sleep, na.rm=T)
mean(age.30s$sleep, na.rm=T)
mean(age.40s$sleep, na.rm=T)
mean(age.50s$sleep, na.rm=T)
mean(age.60s$sleep, na.rm=T)
mean(age.gt.70$sleep, na.rm=T)

sd(males$sleep, na.rm=T)
sd(females$sleep, na.rm=T)
sd(age.lt.30$sleep, na.rm=T)
sd(age.30s$sleep, na.rm=T)
sd(age.40s$sleep, na.rm=T)
sd(age.50s$sleep, na.rm=T)
sd(age.60s$sleep, na.rm=T)
sd(age.gt.70$sleep, na.rm=T)


mean(males$total.act, na.rm=T)
mean(females$total.act, na.rm=T)
mean(age.lt.30$total.act, na.rm=T)
mean(age.30s$total.act, na.rm=T)
mean(age.40s$total.act, na.rm=T)
mean(age.50s$total.act, na.rm=T)
mean(age.60s$total.act, na.rm=T)
mean(age.gt.70$total.act, na.rm=T)

sd(males$total.act, na.rm=T)
sd(females$total.act, na.rm=T)
sd(age.lt.30$total.act, na.rm=T)
sd(age.30s$total.act, na.rm=T)
sd(age.40s$total.act, na.rm=T)
sd(age.50s$total.act, na.rm=T)
sd(age.60s$total.act, na.rm=T)
sd(age.gt.70$total.act, na.rm=T)

write.csv(all.collapse,file="data.withSleep.csv" )




#median age
median(all$age, na.rm=T)
sd(all$age, na.rm=T)

#fraction male:
nrow(males)/nrow(all)

#median moderate or vigorous activity per week (mintes)
median(all.collapse$total.act, na.rm=T) 
mean(all.collapse$total.act, na.rm=T) 


