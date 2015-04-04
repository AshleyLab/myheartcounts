### Health Kit Data Analysis ###

## Julian Homburger
## March 21, 2015
#source("http://depot.sagebase.org/CRAN.R")
#pkgInstall("synapseClient")

# Log in to the client
require(synapseClient)
library(ggplot2)
library(reshape2)
synapseLogin()
setwd('/Users/Julian/Documents/AshleyLab/MHealth/mhealth')

## What did people eat?

dietSurvey <- synTableQuery('select * from syn3354938')
dietTable <- dietSurvey@values

dietDiscrete <- dietTable[,c("recordId", "healthCode", "taskRunId", "fish", "grains", "fruit", "sugar_drinks", "vegetable")]
dietMelt <- melt(dietDiscrete, id.vars=c("recordId", "healthCode", "taskRunId"))
dietMelt$recNum <- as.numeric(as.factor(dietMelt$recordId))

ggplot(aes(x=as.factor(recNum), y=value, fill=variable), data=dietMelt) + geom_bar(stat="Identity") + theme_bw() + 
  labs(x="Individual", y="Counts") + scale_fill_discrete(name="Food")
ggsave("Foods_eaten.pdf", height=6, width=8)

## Lets grab another table and try merging it with the 

satisfied <- synTableQuery('SELECT * FROM syn3354943')
satisfiedTable <- satisfied@values

# Do vegetable make you happy? 
satisfiedDiet <- merge(satisfiedTable, dietTable, by="healthCode")


# Read in the parsed motion data:

motionTrack = read.table("../parsecsvs.txt", head=T, sep="\t")
motionTrack2 = motionTrack[,c("recordId", "SecStationary", "SecWalking", "SecRunning","SecAutomotive", "SecCycling"  )]
motionMelt = melt(motionTrack2, id.vars="recordId", value.vars=c("SecStationary", "SecWalking", "SecRunning","SecAutomotive", "SecCycling"  ))
head(motionMelt)
ggplot(aes(x=as.numeric(as.factor(recordId)), y=value, fill=variable), data=motionMelt) +
  geom_bar(stat="Identity") + theme_bw() + labs(x="IndID", y="Seconds")
ggsave("MotionTrackerTimes.pdf", height=6, width=8)


### Here we start the analysis with the real data ###
### Below we have 

projectId <- "syn3270436"
q <- synQuery(paste("SELECT id, name FROM table WHERE parentId=='", projectId, "'", sep=""))
q

sq <- synTableQuery("SELECT * FROM syn3420385")
risk_factors <- sq@values
sqSub <- synTableQuery("SELECT * FROM syn3420385 WHERE phoneInfo = 'iPhone 6'")
tq <- synTableQuery('SELECT * FROM syn3458480 limit 2')

food_sq <- synTableQuery("SELECT * FROM syn3420518")
food_data_frame <- food_sq@values
food_melt <- melt(food_data_frame, measure.vars=c("vegetable", "fruit", "sugar_drinks", "fish", "grains"))

ggplot(data=food_data_frame) + geom_histogram(aes(x=value,fill=variable), binwidth=1)

day1_sq <- synTableQuery("SELECT * FROM syn3420238")
day1_table <- day1_sq@values
daily_check_sq <- synTableQuery("SELECT * FROM syn3420261")
daily_table <- daily_check_sq@values
ggplot(data=daily_table) + geom_histogram(aes(x=sleep_time/3600))

motion_track <- synTableQuery("SELECT * FROM syn3420486")
motion_track_tables <- motion_track@values

## Going to try to download walk data

tq <- synTableQuery('SELECT * FROM syn3420486 limit 2')

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
    synGet(tq, rn, cc)
  })
})
names(theseFiles) <- theseCols

