### MyHeart App 
### Rachel Goldfeder 

# install 
source("http://depot.sagebase.org/CRAN.R")
pkgInstall("synapseClient")

# load packages
require(synapseClient)
library(ggplot2)
library(reshape2)
library(dplyr)
library(plyr)

synapseLogin()
setwd('/Users/rlg2/Documents/Ashley Lab/Projects/app/')

### example from website

# query your project for all of the tables
projectId <- "syn3270436"
q <- synQuery(paste("SELECT id, name FROM table WHERE parentId=='", projectId, "'", sep=""))

#pull down all obs from a particular survey
sq <- synTableQuery("SELECT * FROM syn3420385")
# head(sq@values)

#pull down all obs from a particular survey for participants on iPhone 6
#sqSub <- synTableQuery("SELECT * FROM syn3420385 WHERE phoneInfo = 'iPhone 6'")
# head(sqSub@values)

motionData <- synTableQuery("SELECT * FROM syn3420486")
motionData.table <- motionData@values

#get a subset of the files associated with the walk task
tq <- synTableQuery('SELECT * FROM syn3458480 limit 2')

sc <- synapseClient:::synGetColumns(tq@schema)
theseCols <- sapply(as.list(1:length(sc)), function(x){
  if(sc[[x]]@columnType=="FILEHANDLEID"){
    return(sc[[x]]@name)
  } else{
    return(NULL)
  }
})
theseCols <- unlist(theseCols)

theseFiles <- lapply(as.list(theseCols), function(cc){
  sapply(as.list(rownames(tq@values)), function(rn){
    synDownloadTableFile(tq, rn, cc)
  })
})
names(theseFiles) <- theseCols




#grab all the tables
motionData <- synTableQuery("SELECT * FROM syn3420486")
motionData.table <- motionData@values

cv_day1 <- synTableQuery("SELECT * FROM syn3420238")
cv_day1.table <- cv_day1@values

parQ <- synTableQuery("SELECT * FROM syn3420257")
parQ.table <- parQ@values

dailyCheck <- synTableQuery("SELECT * FROM syn3420261")
dailyCheck.table <- dailyCheck@values

sleep <- synTableQuery("SELECT * FROM syn3420264")
sleep.table <- sleep@values

riskFactors <- synTableQuery("SELECT * FROM syn3420385")
riskFactors.table <- riskFactors@values

diet <- synTableQuery("SELECT * FROM syn3420518")
diet.table <- diet@values

satisfied <- synTableQuery("SELECT * FROM syn3420615")
satisfied.table <- satisfied@values

# there isn't anything in this one?
ios.survey <- synTableQuery("SELECT * FROM syn3474938")
survey.table <- ios.survey@values

### need to do other things to get the 6 min walk test... 


#satisfied with life distribution
ggplot(data=satisfied.table, aes(satisfiedwith_life)) +geom_histogram()

# just random demographic stuff
table(sq@values$phoneInfo) #notice we are probably enriching for early adapters  - check out all those iphone 6's!
test=sq@values

#phone type
mdata = melt(test, id=c("phoneInfo"))

ggplot(mdata[mdata$variable=="recordId",], aes(variable, fill=phoneInfo)) + geom_bar()+ coord_polar(theta="y") +
  theme_bw() +xlab("") + ylab("") +labs(fill='Phone Type') + theme(axis.ticks=element_blank())


#curious about risk factors vs diet 
dietRisk <- merge(diet.table,riskFactors.table, by="healthCode")
# family history, 1 = males, 2= females, 3 = no, for heart disease 7 =no, others are disease
dietRisk.sm = data.frame(fruitVeggie = dietRisk$fruit+dietRisk$vegetable, history = dietRisk$family_history, disease = dietRisk$heart_disease)

#summarize intelligently
dietRisk.sm[dietRisk.sm$history=="[3]",4]="None" 
dietRisk.sm[dietRisk.sm$disease=="[10]",5]="None"
dietRisk.sm[dietRisk.sm$history=="[]",4]="NA" 
dietRisk.sm[dietRisk.sm$disease=="[]",5]="None"
dietRisk.sm[dietRisk.sm$history!="[3]" &dietRisk.sm$history!="[]",4]="History"
dietRisk.sm[dietRisk.sm$disease!="[10]" &dietRisk.sm$disease!="[]" ,5]="Disease"

colnames(dietRisk.sm) = c(colnames(dietRisk.sm)[1:3],"hist","dis")

#plot. Not much of a difference. slightly higher mean for disease vs none, pretty close for history vs none
ggplot(dietRisk.sm, aes(x=dis, y=fruitVeggie)) + geom_boxplot()
ggplot(dietRisk.sm, aes(x=hist, y=fruitVeggie)) + geom_boxplot()


sleep.sm = data.frame(needed=sleep.table$sleep_time1, get = sleep.table$sleep_time)
#remove NAs and extremes
sleep.sm.noNA = na.omit(sleep.sm)
sleep.sm.clean = sleep.sm.noNA[sleep.sm.noNA$needed>0 & sleep.sm.noNA$needed<24 & sleep.sm.noNA$get>0 & sleep.sm.noNA$get<24 ,]


#plot sleep needed vs sleep get
ggplot(sleep.sm.clean, aes(needed, get)) +geom_point()
sleep.ct = count(sleep.sm.clean)
ggplot(sleep.ct, aes(needed, get, colour =log(freq) )) +geom_point()  + scale_colour_continuous(low= "grey", high="red") + theme_bw() +ggtitle("Hours of sleep per night")


#difference between sleep needed and sleep got vs fruit & veggies, vs exercise
dietSleep <- merge(diet.table,sleep.table, by="healthCode")
dietSleep.clean = dietSleep[dietSleep$sleep_time1>0 & dietSleep$sleep_time1<24 &dietSleep$sleep_time>0 & dietSleep$sleep_time<24 ,]
dietSleep.clean.sm = data.frame(fruitVeggie = dietSleep.clean$fruit+dietSleep.clean$vegetable, sleep_debt = dietSleep.clean$sleep_time1 - dietSleep.clean$sleep_time)
dietSleep.ct =count(dietSleep.clean.sm)

#need to remove weird cases
ggplot(dietSleep.ct, aes(sleep_debt,fruitVeggie, colour = freq)) +geom_point()
ggplot(dietSleep.ct, aes(as.factor(sleep_debt),fruitVeggie)) +geom_boxplot() +xlab("Average Sleep Debt (hrs)") +ylab("Servings of fruits and veggies per day") +theme_bw()
# people who get more as much or more sleep than they need eat more fruit and veggies, too!


# vs moderate + vigorous activity
exerciseSleep.clean.sm = data.frame(exercise = dietSleep.clean$vigorous_act+dietSleep.clean$moderate_act, sleep_debt = dietSleep.clean$sleep_time1 - dietSleep.clean$sleep_time)
exerciseSleep.ct = count(exerciseSleep.clean.sm)
ggplot(exerciseSleep.ct, aes(as.factor(sleep_debt),log(exercise))) +geom_boxplot() +xlab("Average Sleep Debt (hrs)") +ylab("Log(Minutes of Moderate + Vigorous exercise per week)") +theme_bw()


#sleep debt vs happiness
exerciseSleep.satisfied <- merge(dietSleep, satisfied.table, by="healthCode")
exerciseSleep.satisfied.clean = exerciseSleep.satisfied[exerciseSleep.satisfied$sleep_time1>0 & exerciseSleep.satisfied$sleep_time1<24 &exerciseSleep.satisfied$sleep_time>0 & exerciseSleep.satisfied$sleep_time<24 ,]


exerciseSleep.satisfied.sm=data.frame(sleep_debt =exerciseSleep.satisfied.clean$sleep_time1 - exerciseSleep.satisfied.clean$sleep_time, happy=exerciseSleep.satisfied.clean$satisfiedwith_life)
exerciseSleep.satisfied.ct = count(exerciseSleep.satisfied.sm)
ggplot(exerciseSleep.satisfied.ct, aes(as.factor(sleep_debt),happy)) +geom_boxplot() +xlab("Average Sleep Debt (hrs)") +ylab("Satisfied with Life") +theme_bw()
#no association with happiness...










### APRIL 7th 2015 ###


# join parQ with risk factors and diet based on healthcodeID

# notes: lots of people answered the parQ (27K, only 16.8k answered risk factor and 16.8k answered diet)
# lets keep only one row per person
# join and only keep people who answered all 3 of these surveys.

#distinct each file
diet.distinct = distinct(diet.table, healthCode)
parQ.distinct = distinct(parQ.table, healthCode)
riskFactors.distinct = distinct (riskFactors.table, healthCode)

#join
dietparQ <- merge(diet.distinct,parQ.distinct, by="healthCode")
diet.parQ.risk <- merge(dietparQ, riskFactors.distinct, by="healthCode")  #16339 people here. 41 cols.

#glms:

###diet & parQ:
glm(chestPainInLastMonth~fish+fruit+grains+sugar_drinks+vegetable,data=diet.parQ.risk, family=binomial) #need family=binomial for logistic
#kinda cool - fish, fruit, and veggies are neg and grains and sugar drinks are positive (all are TINY of course)

glm(chestPainInLastMonth~fish,data=diet.parQ.risk, family=binomial) #need family=binomial for logistic
glm(chestPainInLastMonth~fruit,data=diet.parQ.risk, family=binomial) #need family=binomial for logistic
glm(chestPainInLastMonth~grains,data=diet.parQ.risk, family=binomial) #need family=binomial for logistic
glm(chestPainInLastMonth~sugar_drinks,data=diet.parQ.risk, family=binomial) #need family=binomial for logistic
glm(chestPainInLastMonth~vegetable,data=diet.parQ.risk, family=binomial) #need family=binomial for logistic








glm(dizziness~fish+fruit+grains+sugar_drinks+vegetable,data=diet.parQ.risk, family=binomial)
# fruit, grains, and sugar are now positive - maybe bc of the sugar in fruit?

#others...
glm(heartCondition~fish+fruit+grains+sugar_drinks+vegetable,data=diet.parQ.risk, family=binomial)
glm(jointProblem~fish+fruit+grains+sugar_drinks+vegetable,data=diet.parQ.risk, family=binomial)
glm(physicallyCapable~fish+fruit+grains+sugar_drinks+vegetable,data=diet.parQ.risk, family=binomial)
glm(prescriptionDrugs~fish+fruit+grains+sugar_drinks+vegetable,data=diet.parQ.risk, family=binomial)
glm(chestPain~fish+fruit+grains+sugar_drinks+vegetable,data=diet.parQ.risk, family=binomial) 

#lasso?
#install.packages('glmnet')
#library(glmnet)
#glmnet(chestPainInLastMonth~fish+fruit+grains+sugar_drinks+vegetable,data=diet.parQ.risk, family=binomial)

###risk data & parQ
glm(chestPainInLastMonth~family_history, data=diet.parQ.risk, family=binomial)
glm(chestPainInLastMonth~heart_disease, data=diet.parQ.risk, family=binomial)
glm(chestPainInLastMonth~medications_to_treat, data=diet.parQ.risk, family=binomial)
glm(chestPainInLastMonth~vascular, data=diet.parQ.risk, family=binomial)

#the risk data needs to be parsed better. ie: [1,2,3] ==[3,2,1]




###dailycheck: is amt of activity correlated with sleep time?

dailyCheck.uniq = as.data.frame(distinct(data.frame(createdOn=dailyCheck.table$createdOn, healthCode=dailyCheck.table$healthCode, activity1_time=dailyCheck.table$activity1_time,activity2_time=dailyCheck.table$activity2_time, sleep_time=dailyCheck.table$sleep_time)))
dailyCheck.uniq$activity1_time=as.numeric(as.character(dailyCheck.uniq$activity1_time))
dailyCheck.uniq$activity2_time=as.numeric(as.character(dailyCheck.uniq$activity2_time))
dailyCheck.uniq[is.na(dailyCheck.uniq)] <-0
dailyCheck.sm = data.frame(total_act = dailyCheck.uniq$activity1_time + dailyCheck.uniq$activity2_time, sleep = dailyCheck.uniq$sleep_time)

#correlation between sleep and activity?
cor(dailyCheck.sm$total_act, as.numeric(as.character(dailyCheck.sm$sleep)))
hist(log(dailyCheck.sm$total_act))
hist(as.numeric(as.character(dailyCheck.sm$sleep)))

# i wonder if i should remove the 60s from the sleep? maybe that is the default (ie: meaning that nothing was actually selected?)
dailyCheck.sm.no60 = dailyCheck.sm[!(dailyCheck.sm$sleep==60),]
hist(log(dailyCheck.sm.no60$total_act))
hist(as.numeric(as.character(dailyCheck.sm.no60$sleep))/3600)
cor(dailyCheck.sm.no60$total_act, as.numeric(as.character(dailyCheck.sm.no60$sleep)))

#can i check that sleep they say they get lines up with what they actually get (from activity check)?
##TODO

#how many days do i have per person? can i check for sleep consistency?
healthCode.ct = count(dailyCheck.uniq$healthCode)
#par(mfrow=c(4, 2))

sd_vec.act =c()
mean_vec.act=c()
sd_vec.sleep =c()
mean_vec.sleep=c()
people.who.never.exercise=0
people.who.exercise=0
fraction.days.with.exercise=c()
for (i in 1:nrow(healthCode.ct)){
  if(healthCode.ct$freq[i]>5){  #5 is arbitrary... could require only more than 1 record...
  
    a = subset(dailyCheck.uniq,dailyCheck.uniq$healthCode==healthCode.ct[i,1])
    a$act_time = a$activity1_time+a$activity2_time
    non0_act_time = a$act_time[a$act_time>0]
    mean_vec.act = append(mean_vec.act, mean(non0_act_time))
    sd_vec.act =append(sd_vec.act, sd(non0_act_time))
    if (length(non0_act_time)>0){
      people.who.exercise = people.who.exercise+1
      fraction.days.with.exercise =append(fraction.days.with.exercise, length(non0_act_time)/healthCode.ct$freq[i])
    }
    else{
      people.who.never.exercise = people.who.never.exercise+1
    }
    
    #a$sleep[a$sleep==60]<-0
    
    non0_sleep = a$sleep[a$sleep>60]
    mean_vec.sleep = append(mean_vec.sleep, mean(non0_sleep))
    sd_vec.sleep = append(sd_vec.sleep, sd(non0_sleep))
    
    

    #make tons of plots!
#     plot(a$sleep/3600, ylim=c(0,20),col="red")
#     lines(a$sleep/3600, col="red")
#     points(a$act_time/3600, col="blue")
#     lines(a$act_time/3600, col="blue")


  }
}
average.act = mean(mean_vec.act, na.rm=T) # on days where you did activity -- overall is ~1hr per day
std.dev.act = mean(sd_vec.act,na.rm=T)
average.sleep = mean(mean_vec.sleep, na.rm=T) # average night sleep 7.11
std.dev.sleep = mean(sd_vec.sleep, na.rm=T)

par(mfrow=c(2,1))
hist(mean_vec.sleep/3600, main="Average sleep per night", xlab="Average # Hours Sleep", col="skyblue1")
hist(sd_vec.sleep/3600, main="Variation in sleep per night", xlab="Standard Deviation (Hours)", col="skyblue4")
hist(mean_vec.act/60, main="Average exercise per day (on days you exercised)", xlab="Average Minutes Excercised",breaks=20,col="skyblue1")
hist(sd_vec.act/60, main="Variation in exercise per day", xlab="Standard Deviation (Minutes)",col="skyblue4")

mean(fraction.days.with.exercise) * 7













###### April 8, 2015
# want to find this table and use it for demographic info cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1
demographics <- synTableQuery("SELECT * FROM syn3458936")
demo.table <- demographics@values

#important fields: healthCode, heartAgeDataAge, bloodPressureInstruction, heartAgeDataBloodGlucose, heartAgeDataDiabetes, heartAgeDataGender
# heartAgeDataEthnicity, heartAgeDataHdl, heartAgeDataHypertension, heartAgeDataLdl.unit, smokingHistory, heartAgeDataSystolicBloodPressure
# heartAgeDataTotalCholesterol, 

demo.table.sm = distinct(data.frame(healthCode = demo.table$healthCode, birthday = demo.table$heartAgeDataAge, bp = demo.table$bloodPressureInstruction, 
                                    bloodGlucose = demo.table$heartAgeDataBloodGlucose, diabetes = demo.table$heartAgeDataDiabetes, sex = demo.table$heartAgeDataGender,
                                    race = demo.table$heartAgeDataEthnicity, hdl = demo.table$heartAgeDataHdl, hypertension=demo.table$heartAgeDataHypertension, 
                                    ldl = demo.table$heartAgeDataLdl, totalChol = demo.table$heartAgeDataTotalCholesterol, smoking = demo.table$smokingHistory, systolic = demo.table$heartAgeDataSystolicBloodPressure))

demo.table.sm.distinct = distinct(demo.table.sm, healthCode) # note, went from 12k records to 5067 records with distinct healthcodes


# now that we've got demographics, lots of fun things to do!

# 0.5) need to parse age

demo.table.sm.distinct$age = as.numeric(difftime("2015-04-08",strptime(demo.table.sm.distinct$birthday,"%Y-%m-%d"), units="weeks"))/52 #divide by 52 to get years

#clean age
demo.table.sm.distinct$age[demo.table.sm.distinct$age>120] <- NA
demo.table.sm.distinct$age[demo.table.sm.distinct$age<0] <- NA

#plot age
par(mfrow=c(1,1))
hist(demo.table.sm.distinct$age, main = "Age distribution", xlab="Age", col = "#e5f5f9")
ggplot(demo.table.sm.distinct, aes(age, fill=race)) + geom_bar() +theme_bw(20)
ggplot(demo.table.sm.distinct, aes(age, fill=sex)) + geom_bar() +theme_bw(20)

# 1) use sex and age and race to look for chestPain vs diet separated by sex and age

#join demo data with diet/parQ data
dietparQ.demo.merge <- merge(dietparQ, demo.table.sm.distinct, by="healthCode") #leaves us with 4953 people

#same glms as before, but with age
glm(chestPainInLastMonth~fish+fruit+grains+sugar_drinks+vegetable+age,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~fish+age,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~fruit+age,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~grains+age,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~sugar_drinks+age,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~vegetable+age,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~age,data=dietparQ.demo.merge, family=binomial)

#same glms as before, but with sex
glm(chestPainInLastMonth~fish+fruit+grains+sugar_drinks+vegetable+sex,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~fish+sex,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~fruit+sex,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~grains+sex,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~sugar_drinks+sex,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~vegetable+sex,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~sex,data=dietparQ.demo.merge, family=binomial) 

#same glms as before, but with race
glm(chestPainInLastMonth~fish+fruit+grains+sugar_drinks+vegetable+race,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~fish+race,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~fruit+race,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~grains+race,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~sugar_drinks+race,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~vegetable+race,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~race,data=dietparQ.demo.merge, family=binomial) 

# race+age+sex combos
glm(chestPainInLastMonth~race+sex,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~race+age,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~sex+age,data=dietparQ.demo.merge, family=binomial) 
glm(chestPainInLastMonth~sex+age+race,data=dietparQ.demo.merge, family=binomial) 

#NONE of these are significant at all.. 





# 2) difference in age / sex / race of who isn't exercising at all? or who exercises the most?

## Note, this code is basically redundant with above. Just copying and pasting for easier manipulation.
healthCode.ct = count(dailyCheck.uniq$healthCode)

sd_vec.act =c()
mean_vec.act=c()
sd_vec.sleep =c()
mean_vec.sleep=c()
people.who.never.exercise=0
people.who.exercise=0
fraction.days.with.exercise=c()
people.hCode=c()
people.who.never.exercise.hCode=c()
people.who.exercise.hCode=c()
for (i in 1:nrow(healthCode.ct)){
  if (i%%500==0){
    print(i)
  }
  if(healthCode.ct$freq[i]>5){  #5 is arbitrary... could require only more than 1 record...
    
    a = subset(dailyCheck.uniq,dailyCheck.uniq$healthCode==healthCode.ct[i,1])
    a$act_time = a$activity1_time+a$activity2_time
    non0_act_time = a$act_time[a$act_time>0]
    mean_vec.act = append(mean_vec.act, mean(non0_act_time))
    sd_vec.act =append(sd_vec.act, sd(non0_act_time))
    people.hCode = append( people.hCode, as.character(healthCode.ct$x[i]))
    if (length(non0_act_time)>0){
      people.who.exercise = people.who.exercise+1
      fraction.days.with.exercise =append(fraction.days.with.exercise, length(non0_act_time)/healthCode.ct$freq[i])
      people.who.exercise.hCode = append( people.who.exercise.hCode, as.character(healthCode.ct$x[i]))
    }
    else{
      people.who.never.exercise = people.who.never.exercise+1
      people.who.never.exercise.hCode = append( people.who.never.exercise.hCode, as.character(healthCode.ct$x[i]))
    }
      
    non0_sleep = a$sleep[a$sleep>60]
    mean_vec.sleep = append(mean_vec.sleep, mean(non0_sleep))
    sd_vec.sleep = append(sd_vec.sleep, sd(non0_sleep))

    
  }
}


# Now, I want to calculate all of these things, but use health code info to break down by race, gender, and age.

# Average sleep per night, next to health code, age, gender, race
# Notes:
# demo.table.sm.distinct has healthcode, age, race, sex
# people.hCode has order of people
# mean_vec.act has mean activity

#merge all that together
hCode.activity = data.frame(mean.act = mean_vec.act, sd.act=sd_vec.act, mean.sleep = mean_vec.sleep, sd.sleep=sd_vec.sleep, healthCode = people.hCode )
hCode.activity.demo = merge(hCode.activity, demo.table.sm.distinct, by = "healthCode")


#### SEX #####

sex.act = matrix(nrow=length(unique(hCode.activity.demo$sex)),ncol=3)
sex.sleep = matrix(nrow=length(unique(hCode.activity.demo$sex)),ncol=3)
ct=1
for (g in unique(hCode.activity.demo$sex)){
  s = subset(hCode.activity.demo, sex == g)

  #activity
  s.avg = mean(s$mean.act,na.rm=T)
  s.stdev = mean(s$sd.act, na.rm=T)
  sex.act[ct,1]=g
  sex.act[ct,2]=s.avg
  sex.act[ct,3]=s.stdev
  
  #sleep
  s.avg = mean(s$mean.sleep,na.rm=T)
  s.stdev = mean(s$sd.sleep, na.rm=T)
  sex.sleep[ct,1]=g
  sex.sleep[ct,2]=s.avg
  sex.sleep[ct,3]=s.stdev
  ct=ct+1
}

#ladies
s = subset(hCode.activity.demo, sex == "[\"HKBiologicalSexFemale\"]" )
sd(s$mean.sleep, na.rm=T)/3600

#gents
s = subset(hCode.activity.demo, sex == "[\"HKBiologicalSexMale\"]" )
sd(s$mean.sleep, na.rm=T)/3600

#put those numbers here: gender, avg, std dev)
#note each data point is an average for an individual

sex_sleep =read.table(text = "Male 7.06 .928 
           Female 7.27 1.015")
limits <- aes(ymax = sex_sleep$V2 + sex_sleep$V3, ymin=sex_sleep$V2 - sex_sleep$V3)
ggplot(sex_sleep, aes(V1, V2)) +geom_bar(identity="stat", fill="skyblue3") + theme_bw(20) + xlab("") +ylab("Hours Sleep") + geom_errorbar(limits, width = .25)

#### RACE #####

race.act = matrix(nrow=length(unique(hCode.activity.demo$race)),ncol=3)
race.sleep = matrix(nrow=length(unique(hCode.activity.demo$race)),ncol=3)
ct=1
for (r in unique(hCode.activity.demo$race)){
  s = subset(hCode.activity.demo, race == r)
  
  #activity
  s.avg = mean(s$mean.act,na.rm=T)
  s.stdev = mean(s$sd.act, na.rm=T)
  race.act[ct,1]=r
  race.act[ct,2]=s.avg
  race.act[ct,3]=s.stdev
  
  #sleep
  s.avg = mean(s$mean.sleep,na.rm=T)
  s.stdev = mean(s$sd.sleep, na.rm=T)
  race.sleep[ct,1]=r
  race.sleep[ct,2]=s.avg
  race.sleep[ct,3]=s.stdev
  ct=ct+1
}

race.sleep.df = as.data.frame(race.sleep)
race.sleep.df$hrs = as.numeric(as.character(race.sleep.df$V2))/3600
ggplot(race.sleep.df, aes(x=V1,y=hrs)) +geom_bar(col="black") +theme_bw(20) +ylab("Average Hours of Sleep per Night") +xlab("Race") 


race.act.df = as.data.frame(race.act)
race.act.df$hrs = as.numeric(as.character(race.act.df$V2))/3600
ggplot(race.act.df, aes(x=V1,y=hrs)) +geom_bar(identity="stat") +theme_bw(20) +ylab("Average Hours of Activity per Day") +xlab("Race") 



#### AGE #####

age.act = matrix(nrow=length(unique(round(hCode.activity.demo$age))),ncol=3)
age.sleep = matrix(nrow=length(unique(round(hCode.activity.demo$age))),ncol=3)
ct=1
for (a in unique(round(hCode.activity.demo$age))){
  s = subset(hCode.activity.demo, round(age) == a)
  
  #activity
  s.avg = mean(s$mean.act,na.rm=T)
  s.stdev = mean(s$sd.act, na.rm=T)
  age.act[ct,1]=a
  age.act[ct,2]=s.avg
  age.act[ct,3]=s.stdev
  
  #sleep
  s.avg = mean(s$mean.sleep,na.rm=T)
  s.stdev = mean(s$sd.sleep, na.rm=T)
  age.sleep[ct,1]=a
  age.sleep[ct,2]=s.avg
  age.sleep[ct,3]=s.stdev
  ct=ct+1
}

age.sleep.df=as.data.frame(age.sleep)
age.sleep.df$hrs = age.sleep.df$V2/3600
age_counts = count(round(hCode.activity.demo$age))
age = merge(age.sleep.df, age_counts, by.x="V1", by.y="x")
ggplot(age, aes(x=V1,y=hrs)) +geom_point(col="black") +theme_bw(20) +ylab("Average Hours of Sleep per Night") +xlab("Age") + geom_smooth(lwd=2,se=FALSE)

age.act.df = as.data.frame(age.act)
age.act.df$hrs = age.act.df$V2/3600


ggplot(age.act.df, aes(x=V1,y=hrs)) +geom_point(col="black") +theme_bw(20) +ylab("Average Hours of Activity") +xlab("Age") + geom_smooth(lwd=2,se=FALSE)



# par(mfrow=c(2,1))
# hist(mean_vec.sleep/3600, main="Average sleep per night", xlab="Average # Hours Sleep", col="skyblue1")
# hist(sd_vec.sleep/3600, main="Variation in sleep per night", xlab="Standard Deviation (Hours)", col="skyblue4")
# hist(mean_vec.act/60, main="Average exercise per day (on days you exercised)", xlab="Average Minutes Excercised",breaks=20,col="skyblue1")
# hist(sd_vec.act/60, main="Variation in exercise per day", xlab="Standard Deviation (Minutes)",col="skyblue4")
# 
# mean(fraction.days.with.exercise) * 7



# now let's look at who did vs didn't exercise by race, gender, and age

exercise = subset(demo.table.sm.distinct, healthCode %in% people.who.exercise.hCode) # dim = 2815 (who have demo data and exercise)
no.exercise = subset(demo.table.sm.distinct, healthCode %in% people.who.never.exercise.hCode) # dim = 1223 (who have demo data and no exercise)

all = subset(demo.table.sm.distinct, healthCode %in% people.who.never.exercise.hCode | healthCode %in% people.who.exercise.hCode)

exercise.rd.age=data.frame(age= round(exercise$age))
no.exercise.rd.age=data.frame(age =round(no.exercise$age))


age.count.exercise = count(exercise.rd.age, "age")
age.count.no.exercise = count(no.exercise.rd.age, "age")

age.ex.noEx = merge(age.count.exercise, age.count.no.exercise, by ="age")

age.ex.noEx$tot = age.ex.noEx$freq.x + age.ex.noEx$freq.y
colnames(age.ex.noEx) = c("age", "ex","no.ex","tot")

par(mfrow=c(1,1))
plot(age.ex.noEx$age, age.ex.noEx$ex/age.ex.noEx$tot, xlim=c(0,100), ylim=c(0,1), main = "Exercise by age", ylab="Fraction of people at a given age", xlab="Age",col="red")
points(age.ex.noEx$age, age.ex.noEx$no.ex/age.ex.noEx$tot, xlim=c(0,100), ylim=c(0,1), main="no exercise",col="blue")
legend("topright",col=c("red", "blue"), c("Exercise", "No Exercise"),pch=1)

ex.df = data.frame(ct = c(536,2261,122,1092),sex=c("F","M","F","M"),ex=c("Y","Y","N","N"))

require(gridExtra)


#gender
p1<-ggplot(ex.df[ex.df$ex=="N",],aes(ex, ct,fill=sex)) + geom_bar()+ coord_polar(theta="y") +
  theme_bw() +xlab("") + ylab("") +labs(fill='sex') + theme(axis.ticks=element_blank()) + ggtitle("No Exercise")

p2<-ggplot(ex.df[ex.df$ex=="Y",],aes(ex, ct,fill=sex)) + geom_bar()+ coord_polar(theta="y") +
  theme_bw() +xlab("") + ylab("") +labs(fill='sex') + theme(axis.ticks=element_blank()) + ggtitle("Exercise")

grid.arrange(p1, p2, ncol=2)

#bp
p1 = ggplot(exercise, aes(bp)) + geom_bar() +theme_bw() + ggtitle("Exercise - BP")
p2 = ggplot(no.exercise, aes(bp)) + geom_bar() +theme_bw()+ ggtitle("No Exercise - BP")

grid.arrange(p1, p2)

#bloodGlucose

p1 = ggplot(exercise, aes(bloodGlucose)) + geom_bar() +theme_bw() + ggtitle("Exercise - blood glucose")
p2 = ggplot(no.exercise, aes(bloodGlucose)) + geom_bar() +theme_bw()+ ggtitle("No Exercise - blood glucose")

grid.arrange(p1, p2)





#race

p1 = ggplot(exercise, aes(race)) + geom_bar() +theme_bw() + ggtitle("Exercise - BP")
p2 = ggplot(no.exercise, aes(race)) + geom_bar() +theme_bw()+ ggtitle("No Exercise - BP")

grid.arrange(p1, p2)
thing1<-cbind(exercise, rep("Exercise",nrow(exercise)))
thing2<-cbind(no.exercise,rep("No Exercise",nrow(no.exercise)))
colnames(thing1)[15]=c("ex")
colnames(thing2)[15]=c("ex")
all<-rbind(thing1,thing2 )
ggplot(all, aes(ex, fill=race)) + geom_bar() +xlab("")

p2<-ggplot(all, aes(ex, fill=diabetes)) + geom_bar()+xlab("")

p4<- ggplot(all, aes(ex, fill=hypertension)) + geom_bar()+xlab("")

p5<- ggplot(all, aes(ex, fill=smoking)) + geom_bar()+xlab("")
grid.arrange(p2,p4,p5)



#exercise vs no exercise & satisfied with life

exercise.satisfied = merge(exercise, distinct(satisfied.table, healthCode), by="healthCode")
no.exercise.satisfied = merge(no.exercise, distinct(satisfied.table, healthCode), by="healthCode")

thing1<-cbind(exercise.satisfied, rep("Exercise",nrow(exercise.satisfied)))
thing2<-cbind(no.exercise.satisfied,rep("No Exercise",nrow(no.exercise.satisfied)))
colnames(thing1)[32]=c("ex")
colnames(thing2)[32]=c("ex")
all<-rbind(thing1,thing2 )

ggplot(all, aes(ex, satisfiedwith_life)) + geom_boxplot() +theme_bw(20) +ylab("Satisfied with life") + xlab("")
ggplot(all, aes(ex, satisfiedwith_life)) + geom_violin() +theme_bw(20) +ylab("Satisfied with life")


# 3) age / sex / race of sleep debt
#later.

# 4) age / sex /race of sleep consistency and average amt 
#done above

# 5) age / sex /race satisfied with life

satisfied.demo = merge(distinct(satisfied.table, healthCode), demo.table.sm.distinct, by="healthCode")
satisfied.demo$age<-round(satisfied.demo$age/10)*10
satisfied.demo<-satisfied.demo[!is.na(satisfied.demo$age),]
ggplot(satisfied.demo, aes(as.factor(age), satisfiedwith_life)) + geom_boxplot() +theme_bw(20) +ylab("Satisfied with life") + xlab("")

ggplot(satisfied.demo, aes(race, satisfiedwith_life)) + geom_boxplot() +theme_bw(20) +ylab("Satisfied with life") + xlab("")

ggplot(satisfied.demo, aes(sex, satisfiedwith_life)) + geom_boxplot() +theme_bw(20) +ylab("Satisfied with life") + xlab("")






#Motion Data

#walking correlated with running? running correlated with cycling?
motion<-read.table("mFileIndParse.txt", as.is=T, sep="\t", header=T)
plot(motion$SecWalking/motion$SecTotal, motion$SecRunning/motion$SecTotal)
plot(motion$SecWalking/motion$SecTotal, motion$SecCycling/motion$SecTotal)
plot(motion$SecRunning/motion$SecTotal, motion$SecCycling/motion$SecTotal)
# meh, not really.

#any extreme athletes in there?
extreme.motion =motion[motion$SecRunning/motion$SecTotal> 0.02 & motion$SecCycling/motion$SecTotal > .02,]
plot(extreme.motion$SecRunning/extreme.motion$SecTotal, extreme.motion$SecCycling/extreme.motion$SecTotal)
# this is really uninteresting.


# Now I want to know if consistency is better or worse for you!
# unknown = 0
# stationary = 1
# walking = 2
# running = 3
# car = 4
# cycling = 5

# so, let's collapse stationary and car => stationary
# walking stays by itself as mild exercise?
# cycling & running collapses to real exercise
# have lots of NAs/unknown, so need to toss those out.

#test.data<-read.table("testBigTable.txt", as.is=T, sep="\t", header=T)

data<-read.table("bigTable.txt", as.is=T, sep="\t", header=T)
test.data = data



#View(test.data)
#cols are individuals, rows are seconds

#define consistent exercise as more than 5 {2,3, or 5} in a row.
test.people = test.data[,7:ncol(test.data)]
test.people[is.na(test.people)]<-0 #NAs are annoying. make them 0s
test.people[test.people==4]<-1 # collapse all sitting behavior
test.people[test.people==5]<-3 # collapse all exercising behavior
test.people$date=paste(test.data$Month, test.data$Day, sep=".")

test.people.save.for.later <- test.people

#just testing things to see what i might expect.
# par(mfrow=c(3,2))
# plot(test.people[,1])
# plot(test.people[,2])
# plot(test.people[,3])
# plot(test.people[,4])
# plot(test.people[,5])
# plot(test.people[,6])
# plot(test.people[,95])


# lets try some smoothing. 
# turn all 3's within 5 of each other into 3's

#this is more important for the within day thing. if i dont do this, i can just count minutes exercised per day. so total per day consistency.
#need to figure out when recordigs start and stop for and individual. I think I can do this by just not making a recording on any day with only 0's.

for (person in 1:ncol(test.people)){
  for (i in 1:nrow(test.people)){
   if(test.people[i,person]==3){
     if(test.people[(i+2), person]==3){
       test.people[(i+1), person]=3
     }
     if(test.people[(i+3), person]==3){
       test.people[(i+1), person]=3
       test.people[(i+2), person]=3       
     }
     if(test.people[(i+4), person]==3){
       test.people[(i+1), person]=3
       test.people[(i+2), person]=3       
       test.people[(i+3), person]=3  
     }
   }
  }
}

# 2 is walking, 3 is exercise. I want to know per day HOW MANY TIMES you did a 2 or a 3 per day

# need to somehow keep track of the lengths of each block, too. #TODO.
blocks.per.day=matrix(ncol=length(unique(test.people$date)), nrow=(ncol(test.people)-1))
index = 1 # date number

for (a in unique(test.people$date)){  
  test.people.date = subset(test.people, date==a ) # all the data for all the people on day a.
  
  for (person in 1:(ncol(test.people)-1)){ # person number
    num.blocks=0 #count number of blocks
    for (i in 1:(nrow(test.people.date)-1)){ # i just indexes the rows from each person for day a
     if(test.people.date[(i+1), person]==3 & test.people.date[(i+1), person] - test.people.date[i, person] != 0){
       num.blocks=num.blocks+1
      }
     
    }
    blocks.per.day[person,index]=num.blocks
       
  }
  index=index+1
}


#now that we've filled in blocks per day, calculate mean and stdev across rows with apply


standard.dev = apply(blocks.per.day,1,sd)
mean = apply(blocks.per.day,1,mean)


#[probably important to know the length of the blocks too.... ], the above is just the NUMBER of blocks.

#grab healthcodes for these people
individual.healthCode = colnames(test.data)[7:ncol(test.data)]

#now the question would be weather low standard dev is better than high mean. 
df<-data.frame(std.dev = standard.dev, healthCode = individual.healthCode, mean = mean)
df.satisfied <- join (df, satisfied.table, by="healthCode")


#maybe remove people who are mean AND standard dev of 0.
# figure out when to stop doing the analysis (ie if at the end they dont have recordings) TODO.


