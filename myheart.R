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
exerciseSleep.clean = data.frame(exercise = dietSleep.clean$vigorous_act+dietSleep.clean$moderate_act, sleep_debt = dietSleep.clean$sleep_time1 - dietSleep.clean$sleep_time)
#exerciseSleep.clean.sm = exerciseSleep.clean$exercise < 
exerciseSleep.ct = count(exerciseSleep.clean.sm)
ggplot(exerciseSleep.ct, aes(as.factor(sleep_debt),log(exercise))) +geom_boxplot() +xlab("Average Sleep Debt (hrs)") +ylab("Log(Minutes of Moderate + Vigorous exercise per week)") +theme_bw()

