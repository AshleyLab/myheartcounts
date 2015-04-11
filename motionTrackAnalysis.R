### Motion Tracker Data Analysis
setwd("/Users/Julian/Documents/AshleyLab/MHealth/MotionTrackData")
# Read in individual data

indiv_all = read.table("mFileIndParse.txt", sep="\t", head=T)

# Read in time data

time = read.table("mFileTimeParse.txt", sep="\t", head=T)

## Individual Data Analysis

# Generate proportions for comparison:

# Remove people with less than 12 hours of data:

indiv = subset(indiv_all, SecTotal > 3600*12)

indiv$pWalk = indiv$SecWalking/indiv$SecTotal
indiv$pStat = indiv$SecStationary/indiv$SecTotal
indiv$pRun = indiv$SecRunning/indiv$SecTotal
indiv$pCycle = indiv$SecCycling/indiv$SecTotal
indiv$pAuto = indiv$SecAutomotive/indiv$SecTotal

# Basic Stats on the Total Information Collected
pdf("BasicMotionTrackStats.pdf", height=10, width=10)
par(mfrow=c(2,2))
hist((indiv$SecWalking+indiv$SecCycling + indiv$SecRunning)/3600, breaks=100, main="Hours Active, Total", ylab="Number of Individuals", xlab="Hours Active", col="lightblue")
hist(indiv$SecStationary/3600, breaks=100, main="Hours Stationary, Total", ylab="Number of Individuals", xlab="Hours Stationary", col="lightblue")
hist(indiv$SecTotal/3600, breaks=100, main="Hours Not Unknown, Total", ylab="Number of Individuals", col="lightblue", xlab="Hours not Unkwown")
hist(indiv$SecTotUnk/3600, breaks=100, main="Hours Recorded, Total", ylab="Number of Individuals", col="lightblue", xlab="Hours Recorded")
dev.off()

## Basic Stats on the Proportions of Time doing Things
pdf("PropMotionTrackStats.pdf", height=10, width=10)
par(mfrow=c(2,2))
hist((indiv$pWalk+indiv$pCycle + indiv$pRun), breaks=50, main="Proportion Time Active", ylab="Number of Individuals", xlab="Proportion Active", col="lightblue", xlim=c(0,1))
hist(indiv$pStat, breaks=100, main="Proportion Time Stationary", ylab="Number of Individuals", xlab="Proportion Stationary", col="lightblue",xlim=c(0,1))
hist(indiv$pAuto, breaks=100, main="Proportion Time Driving", ylab="Number of Individuals", xlab="Proportion Driving", col="lightblue", xlim=c(0,1))
hist(indiv$SecUnk/indiv$SecTotUnk, breaks=100, main="Proportion of Time Unknown", col="lightblue", xlim=c(0,1), xlab="Proportion Unknown")
dev.off()


### Time data

time_use = subset(time, NumTotal>100)

time_use$pWalk = time_use$NumWalking/time_use$NumTotal
time_use$pStat = time_use$NumStationary/time_use$NumTotal
time_use$pRun = time_use$NumRunning/time_use$NumTotal
time_use$pCycle = time_use$NumCycling/time_use$NumTotal
time_use$pAuto = time_use$NumAutomotive/time_use$NumTotal

hist(time_use$pWalk)
hist(time_use$pRun)
hist(time_use$pAuto)
hist(time_use$pCycle)
hist(time_use$pStat)

ggplot(aes(x=Hour), data=time_use) + geom_histogram(binwidth=1, fill="grey55", col="white") + xlim(c(0,23)) + theme_bw() + labs(y="Count of Times with >100 Observations", x="Hour of the Day", title="Hours of Day with >100 Motion Tracker Observations")
ggsave("HoursOfDay_hist.pdf", height=6, width=8)


ggplot(aes(x=as.factor(Hour), y=pAuto), data=time_use) + geom_boxplot() + theme_bw() + labs(x="Hour of the Day", y="Proportion Automotive", title="Automotive")
ggsave("pAuto_Hour.pdf", height=6, width=8)

ggplot(aes(x=as.factor(Hour), y=pStat), data=time_use) + geom_boxplot() + theme_bw() + labs(x="Hour of the Day", y="Proportion Stationary", title="Stationary")
ggsave("pStat_Hour.pdf", height=6, width=8)

ggplot(aes(x=as.factor(Hour), y=pRun), data=time_use) + geom_boxplot() + theme_bw() + labs(x="Hour of the Day", y="Proportion Running", title="Running")
ggsave("pRun_Hour.pdf", height=6, width=8)

ggplot(aes(x=as.factor(Hour), y=pWalk), data=time_use) + geom_boxplot() + theme_bw() + labs(x="Hour of the Day", y="Proportion Walking", title="Walking")
ggsave("pWalk_Hour.pdf", height=6, width=8)

ggplot(aes(x=as.factor(Hour), y=pCycle), data=time_use) + geom_boxplot() + theme_bw() + labs(x="Hour of the Day", y="Proportion Cycling", title="Cycling")
ggsave("pCycle_Hour.pdf", height=6, width=8)

## Lets try this by the minute of the day:

time_use$dayminute = time_use$Hour*60 + time_use$Minute 
time_use$pActive = time_use$pRun + time_use$pWalk + time_use$pCycle
ggplot(aes(x=dayminute, y=pWalk), data=time_use) + geom_point(alpha=0.07) + theme_bw() + labs(x="Hour of the Day", y="Proportion Walking", title="Walking")
ggsave("pWalk_minute.png", height=6, width=8)

ggplot(aes(x=dayminute, y=pStat), data=time_use) + geom_point(alpha=0.07) + theme_bw() + labs(x="Minute of the Day", y="Proportion Stationary", title="Stationary")
ggsave("pStat_minute.png", height=6, width=8)

ggplot(aes(x=dayminute, y=pRun), data=time_use) + geom_point(alpha=0.07) + theme_bw() + labs(x="Minute of the Day", y="Proportion Running", title="Running")
ggsave("pRun_minute.pdf", height=6, width=8)

ggplot(aes(x=dayminute, y=pAuto), data=time_use) + geom_point(alpha=0.07) + theme_bw() + labs(x="Minute of the Day", y="Proportion Automotive", title="Automotive")


## Time melt:

time_use_sub = time_use[c("Hour", "Day", "Month", "Minute", "dayminute", "pAuto", "pRun", "pStat", "pWalk", "pCycle")]
time_melt = melt(time_use_sub, measure.vars=c("pAuto", "pRun", "pStat", "pWalk", "pCycle"))

ggplot(aes(x=dayminute, y=value, col=variable), data=time_melt) + geom_point(alpha=0.07, pch=19) + theme_bw() + labs(x="Minute of the Day", y="Proportion of Individuals in Specific Activity") + guides(color = guide_legend(override.aes=list(alpha=1)) )
ggsave("ColorfulTimeUse.png",width=12, height=8)
time_use$monthdaystring = paste(time_use$Month,"-", time_use$Day,sep="")
time_use$monthday = time_use$Month*100 + time_use$Day
ggplot(aes(x=as.factor(monthday), y=pRun),data=time_use) + geom_boxplot() + theme_bw() + theme(axis.text.x=element_text(size=14, angle=270, vjust=0.5))

ggplot(aes(x=as.factor(monthday), y=pAuto),data=time_use) + geom_boxplot()

ggplot(aes(x=as.factor(monthday), y=pWalk),data=time_use) + geom_boxplot()

ggplot(aes(x=as.factor(monthday), y=pStat),data=time_use) + geom_boxplot()


### Combine summary data + motion data by health code

motion_satisfy = merge(satisfied_wState, indiv, by="healthCode")

cycle_person = aggregate(motion_satisfy$pCycle, list(motion_satisfy$healthCode), mean)
names(cycle_person) = c("healthCode", "pCycle")
cycle_zip = merge(cycle_person, unique_frame)

avg_zip_cycle = aggregate(cycle_zip$pCycle, list(cycle_zip$zip), mean)
avg_zip_cycle = avg_zip_cycle[order(avg_zip_cycle$x, decreasing=T),]

cycle_state = merge(cycle_person, unique_frame_state)
avg_state_cycle = aggregate(cycle_state$pCycle, list(cycle_state$state), mean)
avg_state_cycle[order(avg_state_cycle$x, decreasing=T),]

### Average number of data points per day?
time$monthday = time$Month*100 + time$Day
ggplot(aes(x=as.factor(monthday), y=NumTotal), data=time) + geom_boxplot() + theme_bw() + labs(y="Number of Observations Each Minute", x="MonthDay")
ggsave("ObservationsByMonthAndDay.pdf", height=6, width=9)

indiv_minDays = as.data.frame(unname(t(as.data.frame(strsplit(as.character(indiv$MinTime), ' ')))))
indiv_minDays$date = as.Date(indiv_minDays$V1, "%Y-%m-%d")

ggplot(aes(x=date), data=indiv_minDays) + geom_histogram(binwidth=1, col="white") + theme_bw() + labs(title="Earliest Motion Tracker Timestamp by Individual")
ggsave("HistogramOfEarliestDay.pdf", height=6, width=9)
### Can we compare 6 minute walk data and Daily Activity Data?



### Let's get the health data (ie. cholesterol, etc)

heartage = synTableQuery("SELECT * FROM syn3458936")
hearttable = heartage@values
hearttable_motion = merge(hearttable, indiv, by="healthCode")
hearttable_motion$pActive = hearttable_motion$pWalk + hearttable_motion$pRun + hearttable_motion$pCycle

hearttable_motion$age = as.numeric(difftime("2015-04-08",strptime(hearttable_motion$heartAgeDataAge,"%Y-%m-%d"), units="weeks"))/52

## Clean the data: Remove Other, no entries, out of range values
hearttable_motion$age[hearttable_motion$age<0] = NA
hearttable_motion$age[hearttable_motion$age>120] =NA

hearttable_motion$heartAgeDataGender[hearttable_motion$heartAgeDataGender=="[]"] = NA 
hearttable_motion$heartAgeDataGender[hearttable_motion$heartAgeDataGender=="[\"HKBiologicalSexOther\"]"] = NA 


## Now, lets analyze Blood Pressure:

# Get a subset of the data with reasonable ranges
bp_use = subset(hearttable_motion, bloodPressureInstruction>=60 & bloodPressureInstruction<220 & pWalk+pRun>0.001)
summary(bp_runwalk.lm <- lm(bloodPressureInstruction~ pWalk + pRun + age + heartAgeDataGender, bp_use))

plot(bp_runwalk.lm)
bp_runwalk_log.lm = lm(bloodPressureInstruction~ log(pWalk+pRun, 10) + age + heartAgeDataGender, data=bp_use)
summary(bp_runwalk_log.lm)
plot(bp_runwalk_log.lm)
summary(bp_runwalk.rlm <-rlm(bloodPressureInstruction~log(pWalk + pRun, 10) + heartAgeDataGender + age, data=bp_use))

ggplot(data=bp_use, aes(x=log(pWalk+pRun), y=bloodPressureInstruction, col=heartAgeDataGender)) + geom_point(alpha=0.7) + theme_bw() + labs(x="Log(Proportion of Time Running + Walking)", y="Systolic Blood Pressure (<220, >60)", title="BP vs. Time Active")
ggsave("BP_vsLogRunWalk.pdf", width=8, height=5)

ggplot(data=bp_use, aes(x=pWalk+pRun, y=bloodPressureInstruction, col=heartAgeDataGender)) + geom_point(alpha=0.7) + theme_bw() + labs(x="Proportion of Time Running + Walking", y="Systolic Blood Pressure (<220, >60)", title="BP vs. Time Active")
ggsave("BP_vsRunWalk.pdf", width=8, height=5)

## Let's look at total cholesterol

chol_use = subset(hearttable_motion, heartAgeDataTotalCholesterol<300 & heartAgeDataTotalCholesterol > 100 & pWalk+pRun>0.001)
summary(chol_runwalk.lm <- lm(heartAgeDataTotalCholesterol~ pWalk + pRun + age + heartAgeDataGender, data=subset(chol_use, log(pWalk+pRun)>-15)))

summary(chol_runwalk_log.lm <- lm(heartAgeDataTotalCholesterol~ log(pWalk + pRun) + age + heartAgeDataGender, data=subset(chol_use, log(pWalk+pRun)>-7.5)))

ggplot(aes(x=pRun+pWalk, y=heartAgeDataTotalCholesterol), data=chol_use) + geom_point() + theme_bw()

ggplot(aes(x=log(pRun+pWalk), y=heartAgeDataTotalCholesterol), data=chol_use) + geom_point() + theme_bw()

summary(chol_runwalk_log.rlm <- rlm(heartAgeDataTotalCholesterol~ log(pWalk + pRun) + age + heartAgeDataGender, data=subset(chol_use, log(pWalk+pRun)>-7.5)))



# Let's do LDL 

ldl_use = subset(hearttable_motion, heartAgeDataLdl<250 & heartAgeDataLdl>25)
summary(ldl_runwalk.lm <- lm(heartAgeDataLdl~ pWalk + pRun + age + heartAgeDataGender, data=subset(ldl_use, log(pWalk+pRun)>-15)))

summary(ldl_runwalk.lm <- lm(heartAgeDataLdl~ log(pWalk + pRun) + age + heartAgeDataGender, data=subset(ldl_use, log(pWalk+pRun)>-15)))




### Old things:
hearttable_motion$bpGood = hearttable_motion$bloodPressureInstruction <120
chol = subset(hearttable_motion, heartAgeDataTotalCholesterol<300 & heartAgeDataTotalCholesterol > 100)
plot(heartAgeDataTotalCholesterol ~ pWalk, data=chol)
chol$lessthan180 = chol$heartAgeDataTotalCholesterol < 180
summary(lm(heartAgeDataTotalCholesterol ~ pWalk + pRun + age, data=chol))
ggplot(data=chol, aes(x=))

summary(lm(heartAgeDataHdl ~ pWalk + age, data=chol))
summary(lm(heartAgeDataSystolicBloodPressure~pActive, data=subset(hearttable_motion, heartAgeDataSystolicBloodPressure>50 & heartAgeDataSystolicBloodPressure<300)))
summary(glm(lessthan180~pWalk + age, data=chol))
# Min fitted values: 9164, 9078

