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
motionTrack2 = motionTrack[c(1,2,5,6),c("recordId", "SecStationary", "SecWalking", "SecRunning","SecAutomotive", "SecCycling"  )]
motionMelt = melt(motionTrack2, id.vars="recordId", value.vars=c("SecStationary", "SecWalking", "SecRunning","SecAutomotive", "SecCycling"  ))
head(motionMelt)
ggplot(aes(x=as.numeric(as.factor(recordId)), y=value, fill=variable), data=motionMelt) +
  geom_bar(stat="Identity") + theme_bw() + labs(x="IndID", y="Seconds")
ggsave("MotionTrackerTimes.pdf", height=6, width=8)

