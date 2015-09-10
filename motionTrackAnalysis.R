### Motion Tracker Data Analysis
setwd("/Users/Julian/Documents/AshleyLab/MHealth/MotionTrackData0412")
# Read in individual data

indiv_all = read.table("/Users/Julian/Documents/AshleyLab/MHealth/2015-04-12/indMotion0412.txt", sep="\t", head=T)

# Read in time data

time = read.table("/Users/Julian/Documents/AshleyLab/MHealth/2015-04-12/timeMotion0412.txt", sep="\t", head=T)

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
pdf("BasicMotionTrackStats0412.pdf", height=10, width=10)
par(mfrow=c(2,2))
hist((indiv$SecWalking+indiv$SecCycling + indiv$SecRunning)/3600, breaks=100, main="Hours Active, Total", ylab="Number of Individuals", xlab="Hours Active", col="lightblue")
hist(indiv$SecStationary/3600, breaks=100, main="Hours Stationary, Total", ylab="Number of Individuals", xlab="Hours Stationary", col="lightblue")
hist(indiv$SecTotal/3600, breaks=100, main="Hours Not Unknown, Total", ylab="Number of Individuals", col="lightblue", xlab="Hours not Unkwown")
hist(indiv$SecTotUnk/3600, breaks=100, main="Hours Recorded, Total", ylab="Number of Individuals", col="lightblue", xlab="Hours Recorded")
dev.off()

## Basic Stats on the Proportions of Time doing Things
pdf("PropMotionTrackStats0412.pdf", height=10, width=10)
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
time_use$pActive = time_use$pRun + time_use$pCycle + time_use$pWalk
time_use$pInactive = time_use$pStat + time_use$pAuto
hist(time_use$pWalk)
hist(time_use$pRun)
hist(time_use$pAuto)
hist(time_use$pCycle)
hist(time_use$pStat)

ggplot(aes(x=Hour), data=time_use) + geom_histogram(binwidth=1, fill="grey55", col="white") + xlim(c(0,23)) + theme_bw() + labs(y="Count of Times with >100 Observations", x="Hour of the Day", title="Hours of Day with >100 Motion Tracker Observations")
ggsave("HoursOfDay_hist0412.pdf", height=6, width=8)


ggplot(aes(x=as.factor(Hour), y=NumTotal), data=time_use) + geom_boxplot() + ylim(c(0,1300)) + theme_bw() + labs(y="Number of Observations Each Minute", x="Hour of the Day", title="Number of Observations")
ggsave("HoursOfDay_boxplot0412.pdf", height=6, width=8)



time_to_plot = data.frame(pActive =time_use$pActive, pInactive=time_use$pInactive, Hour = time_use$Hour, HourMinute=time_use$Hour*60+ time_use$Minute)
time_melt = melt(time_to_plot, id.vars=c("Hour", "HourMinute"))
levels(time_melt$variable) = c("Active", "Inactive")
ggplot(aes(x=as.factor(Hour), y=value), data=time_melt) + facet_grid(~variable) + geom_boxplot(outlier.size=0.75) + theme_bw() + labs(x="Hour of the Day", y="Proportion of Individuals in Given State Each Minute") 
ggsave("DayActiveVsInactive0420.pdf", height=7, width=12)
ggplot(aes(x=as.factor(Hour), y=value, fill=variable), data=time_melt) + geom_boxplot(outlier.size=0.75) + theme_bw() + labs(x="Hour of the Day", y="Proportion of Individuals in Given State Each Minute") + theme(legend.title=element_blank())
ggsave("DayActiveVsInactive_samePlot.pdf", height=7, width=9)



ggplot(aes(x=as.factor(HourMinute), y=value), data=time_melt) + facet_grid(~variable) + geom_point(alpha=0.05) + theme_bw() + labs(x="Minute of the Day", y="Proportion of Individuals in Given State Each Minute") + theme(panel.grid=element_blank(), axis.text.x=element_blank(), axis.ticks.x=element_blank())
ggsave("DayActiveVsInactive_Minute.pdf", height=7, width=12)


ggplot(aes(x=as.factor(Hour), y=pActive), data=time_use) + geom_boxplot() + theme_bw() + labs(x="Hour of the Day", y="Proportion Active", title="Active")

ggplot(aes(x=as.factor(Hour), y=pInactive), data=time_use) + geom_boxplot() + theme_bw() + labs(x="Hour of the Day", y="Proportion Individuals Inactive", title="Inactive")

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
time_use$pInactive = time_use$pStat + time_use$pAuto

ggplot(aes(x=dayminute, y=pActive), data=time_use) + geom_point(alpha=0.07) + theme_bw() + labs(x="Hour of the Day", y="Proportion Walking", title="Walking")




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

## Get summary of heart values

bp_sum = aggregate(hearttable$bloodPressureInstruction, list(hearttable$healthCode), mean)
bp_sum = subset(bp_sum, x>60 & x<220)
mean(bp_sum$x)
median(bp_sum$x)
sd(bp_sum$x)
range(bp_sum$x)

chol_sum = aggregate(hearttable$heartAgeDataTotalCholesterol, list(hearttable$healthCode), mean)
chol_sum = subset(chol_sum, x>100 & x < 400)
mean(chol_sum$x)
median(chol_sum$x)
sd(chol_sum$x)
range(chol_sum$x)

hdl_sum = aggregate(hearttable$heartAgeDataHdl, list(hearttable$healthCode), mean)
hdl_sum = subset(hdl_sum, x>0 & x<200)
mean(hdl_sum$x)
median(hdl_sum$x)
sd(hdl_sum$x)
range(hdl_sum$x)

ldl_sum = aggregate(hearttable$heartAgeDataLdl, list(hearttable$healthCode), mean)
ldl_sum = subset(ldl_sum, x>0 & x<300)
mean(ldl_sum$x)
median(ldl_sum$x)
sd(ldl_sum$x)
range(ldl_sum$x)

hearttable_motion = merge(hearttable, indiv, by="healthCode")
hearttable_motion$pActive = hearttable_motion$pWalk + hearttable_motion$pRun + hearttable_motion$pCycle

hearttable_motion$age = as.numeric(difftime("2015-04-08",strptime(hearttable_motion$heartAgeDataAge,"%Y-%m-%d"), units="weeks"))/52

## Clean the data: Remove Other, no entries, out of range values
hearttable_motion$age[hearttable_motion$age<0] = NA
hearttable_motion$age[hearttable_motion$age>120] =NA

hearttable_motion$heartAgeDataGender[hearttable_motion$heartAgeDataGender=="[]"] = NA 
hearttable_motion$heartAgeDataGender[hearttable_motion$heartAgeDataGender=="[\"HKBiologicalSexOther\"]"] = NA 

# lets fix hearttable age:
age_estimate = aggregate(hearttable_motion$age, list(hearttable_motion$healthCode), mean)
names(age_estimate) = c("healthCode", "age_e")
hearttable_age = merge(hearttable_motion, age_estimate, by.x="healthCode", by.y="healthCode")

## Now, lets analyze Blood Pressure:

# Get a subset of the data with reasonable ranges
bp_use = subset(hearttable_age, bloodPressureInstruction>=60 & bloodPressureInstruction<220 & pWalk+pRun>0.001)
bp_use$MAP = bp_use$heartAgeDataSystolicBloodPressure + (1/3)*(bp_use$bloodPressureInstruction - bp_use$heartAgeDataSystolicBloodPressure)
map_use = subset(bp_use, heartAgeDataSystolicBloodPressure>=20, heartAgeDataSystolicBloodPressure<180 )

bp_use_unique = unique(data.frame(bp = bp_use$bloodPressureInstruction, healthcode=bp_use$healthCode, MAP=bp_use$MAP))
bp_estim = aggregate(bp_use_unique$bp, list(bp_use_unique$healthcode), mean)
map_estim =aggregate(map_use$MAP, list(map_use$healthCode), mean)
names(bp_estim) = c("healthCode", "bp_estim")
names(map_estim) = c("healthCode", "MAP_estim")
bp_use_estim = merge(bp_use, bp_estim, by="healthCode")
bp_use_estim_u = unique(data.frame(bp_estim = bp_use_estim$bp_estim, age = bp_use_estim$age_e, pRun = bp_use_estim$pRun, pWalk = bp_use_estim$pWalk, pActive =  bp_use_estim$pWalk +  bp_use_estim$pRun +  bp_use_estim$pCycle, gender = bp_use_estim$heartAgeDataGender, healthCode=bp_use_estim$healthCode))
plot( bp_use_estim_u$bp_estim ~ (bp_use_estim_u$pWalk +  bp_use_estim_u$pRun))
summary(bp_runwalk.lm <- lm(bp_estim ~ pActive + age + gender, bp_use_estim_u))

plot(bp_runwalk.lm)
bp_runwalk_log.lm = lm(bp_estim ~ log(pActive) + age + gender, data=bp_use_estim_u)
summary(bp_runwalk_log.lm)
plot(bp_runwalk_log.lm)
summary(bp_runwalk.rlm <-rlm(bp_estim ~ log(pActive) + age + gender, data=bp_use_estim_u))

smoothScatter(bp_use$bloodPressureInstruction~ bp_use$pWalk+ bp_use$pRun)

ggplot(data=bp_use, aes(x=log(pWalk+pRun), y=bloodPressureInstruction, col=heartAgeDataGender)) + geom_point(alpha=0.7) + theme_bw() + labs(x="Log(Proportion of Time Running + Walking)", y="Systolic Blood Pressure (<220, >60)", title="BP vs. Time Active")
ggsave("BP_vsLogRunWalk.pdf", width=8, height=5)

ggplot(data=bp_use, aes(x=pWalk+pRun, y=bloodPressureInstruction, col=heartAgeDataGender)) + geom_point(alpha=0.7) + theme_bw() + labs(x="Proportion of Time Running + Walking", y="Systolic Blood Pressure (<220, >60)", title="BP vs. Time Active")
ggsave("BP_vsRunWalk.pdf", width=8, height=5)

#3 Lets add six minute data

sixmin = read.table("../2015-04-12/6minWalk_healthCode_steps.tsv", head=T, sep="\t")
bp_use_estim_six = merge(bp_use_estim_u, sixmin, by="healthCode")
summary(bp_sixmin.lm <- lm(bp_estim ~ numberOfSteps + pActive + age + gender, data=bp_use_estim_six))

summary(bp_sixmin_log.lm <- lm(bp_estim ~ numberOfSteps + log(pActive) + age + gender, data=bp_use_estim_six))



## Mean Arterial PRessure
map_use_estim = subset(merge(bp_use, map_estim, by="healthCode"), MAP_estim < 200)
map_use_estim_u = unique(data.frame(MAP_estim = map_use_estim$MAP_estim, age = map_use_estim$age_e, pRun = map_use_estim$pRun, pWalk = map_use_estim$pWalk, pActive =  map_use_estim$pWalk +  map_use_estim$pRun +  map_use_estim$pCycle, gender = map_use_estim$heartAgeDataGender, healthCode=map_use_estim$healthCode))
hist(map_use_estim_u$MAP_estim)
summary(map_runwalk.lm <- lm(MAP_estim ~ pActive + age + gender, map_use_estim_u))

plot(map_runwalk.lm)
map_runwalk_log.lm = lm(MAP_estim ~ log(pActive) + age + gender, data=map_use_estim_u)
summary(map_runwalk_log.lm)

map_estim_six = merge(map_use_estim_u, sixmin, by="healthCode")
map_six.lm <- lm(MAP_estim ~ distance + pActive + age*gender, data=map_estim_six)
summary(map_six.lm)

map_six_log.lm <- lm(MAP_estim ~ distance + age + log(pActive)+gender, data=map_estim_six)
summary(map_six_log.lm)


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



### Get the day one table

dayone = synTableQuery("SELECT * FROM syn3420238")


### Merge Indiv Table and Zip Codes

indiv_zip = merge(indiv, diet_satisfy_state, by="healthCode")

pWalk_state = aggregate(indiv_zip$pWalk, list(indiv_zip$state), mean)
names(pWalk_state) = c( "State", "pWalk")

stateMapPlot(pWalk_state, "Blues", "pWalk", c(0,0.03,0.04,0.05,0.06,0.07,1), nameStateColumn="State")
mean(indiv$pWalk)

pStat_state = aggregate(indiv_zip$pStat, list(indiv_zip$state), mean)
names(pStat_state)=c("State", "pStat")

stateMapPlot(pStat_state, "Reds", "pStat", c(0, 0.7, 0.72, 0.73, 0.74, 0.75, 0.76, 0.77, 0.78, 1), nameStateColumn="State")

indiv_zip$pActive = indiv_zip$pWalk + indiv_zip$pRun + indiv_zip$pCycle
summary(active_state.lm <- lm(pActive ~ state, data=indiv_zip))
pActive_state = aggregate(indiv_zip$pActive, list(indiv_zip$state), mean)
names(pActive_state)=c("State", "pActive")
pdf("ProportionActivityByState0412.pdf", height=7, width=12)
stateMapPlot(pActive_state, "Blues", "pActive", c(0,0.06,0.07,0.08,0.09,0.10,1), nameStateColumn="State")
legend("bottomright", legend=c("< 6%", "6% - 7%", "7% - 8%", "8% - 9%", "9% - 10%", "> 10%"), fill=brewer.pal(6, "Blues"), box.lty=0, bg=NULL)
title(main="Average Proportion of Time Spent Active by State")
dev.off()

pAuto_state = aggregate(indiv_zip$pAuto, list(indiv_zip$state), mean)
names(pAuto_state) = c("State", "pAuto")
stateMapPlot(pAuto_state, "Purples", "pAuto", c(0,0.1,0.12,0.14,0.16,0.18,0.2,1), nameStateColumn="State")

## Blood Pressure by State

heartzip = merge(bp_use, diet_satisfy_state, by="healthCode" )
summary(bpstate.lm <- lm(bloodPressureInstruction~ state, data=heartzip))
bp_state = aggregate(heartzip$bloodPressureInstruction, c(list(heartzip$state),list(heartzip$healthCode)) , mean)
names(bp_state) = c("state", "healthCode", "bp")
bp_state_u = aggregate(bp_state$bp, list(bp_state$state), mean)
names(bp_state_u) = c("state", "bp")
pdf("BP_byState.pdf", height=6, width=10)
stateMapPlot(bp_state_u, "Reds", "bp", c(100,120,121,122,123,124,150), nameStateColumn="state")
legend("bottomright", legend=c("<120", "120 - 121", "122 - 123", "123 - 124",">124"), fill=brewer.pal(5,"Reds"), box.lty=0, bg=NULL)
dev.off()


## Read in CDC Activity Data

cdc_active = read.csv("../CDC_StateData/exerciseCDCByState.csv")

cdc_tracker = merge(pActive_state, cdc_active, by="State")






