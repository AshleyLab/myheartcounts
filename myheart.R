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

#do something with risk data. it is just really annoying to deal with. come back and parse it properly.




###dailycheck: is amt of activity correlated with sleep time?

dailyCheck.uniq = as.data.frame(distinct(as.data.frame(cbind(dailyCheck.table$createdOn, dailyCheck.table$healthCode, dailyCheck.table$activity1_time,dailyCheck.table$activity2_time, dailyCheck.table$sleep_time))))
dailyCheck.uniq$V3=as.numeric(as.character(dailyCheck.uniq$V3))
dailyCheck.uniq$V4=as.numeric(as.character(dailyCheck.uniq$V4))
dailyCheck.uniq[is.na(dailyCheck.uniq)] <-0
dailyCheck.sm = data.frame(total_act = dailyCheck.uniq$V3 + dailyCheck.uniq$V4, sleep = dailyCheck.uniq$V5)

#correlation between sleep and activity?
cor(dailyCheck.sm$total_act, as.numeric(as.character(dailyCheck.sm$sleep)))
hist(log(dailyCheck.sm$total_act))
hist(as.numeric(as.character(dailyCheck.sm$sleep)))

# i wonder if i should remove the 60s from the sleep? maybe that is the default (ie: 1 hr... meaning that nothing was actually selected?)
dailyCheck.sm.no60 = dailyCheck.sm[!(dailyCheck.sm$sleep==60),]
hist(log(dailyCheck.sm.no60$total_act))
hist(as.numeric(as.character(dailyCheck.sm.no60$sleep)))
cor(dailyCheck.sm.no60$total_act, as.numeric(as.character(dailyCheck.sm.no60$sleep)))


