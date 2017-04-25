rm(list=ls())
source('helpers.R') 
library(data.table) 
library(ggplot2)

#load("activity_state_clusters.bin")
load('full_breakpoints_2') 
load('full_breakpoints_50') 
load('full_breakpoints_100') 
load('full_breakpoints_200') 
#START WITH 100-point MAJORITY VOTE 

#normalize! 
data=subset(features_100,select=c("stationary_day","stationary_end","changes_day","changes_end"))
data$cur_subject=NULL 
data$changes_day=data$changes_day/max(data$changes_day)
data$changes_end=data$changes_end/max(data$changes_end) 
fit=kmeans(data,6,nstart=10)
data$cluster=factor(fit$cluster)
data$changes_day=features_100$changes_day 
data$changes_end=features_100$changes_end
p1<-ggplot(data,aes(stationary_day,stationary_end,colour = cluster)) + geom_point(alpha=1/2) + xlab("Weekday")+ylab("Weekend")+ggtitle("Fraction of Time Subject is Stationary")+theme_bw(15)
p2<-ggplot(data,aes(changes_day,changes_end,colour = cluster)) + geom_point(alpha=1/2)+xlab("Weekday")+ylab("Weekend")+ggtitle("State Changes")+theme_bw(15)
multiplot(p1,p2,cols=2)

#MERGE WITH MEDICAL DATA BY SUBJECT NAME 
data$subject=features_100$cur_subject
conditions=data.frame(read.table("NonTimeSeries.txt",header=T,sep="\t",skip=1,row.names=1))
conditions$subject=rownames(conditions)
merged=merge(data,conditions,by="subject",all.x=TRUE)
browser() 
#ANOVA TESTING & TUKEY TEST FOR CONTINUOUS HEALTH CORRELATIONS! 
aov1<-aov(heartAgeDataBloodGlucose~cluster,data=merged)
tk<-TukeyHSD(aov1,conf.level=0.95)

aov1<-aov(heartAgeDataLdl~cluster,data=merged)
tk<-TukeyHSD(aov1,conf.level=0.95)

aov1<-aov(heartAgeDataTotalCholesterol~cluster,data=merged)
tk<-TukeyHSD(aov1,conf.level=0.95)

aov1<-aov(bloodPressureInstruction~cluster,data=merged)
tk<-TukeyHSD(aov1,conf.level=0.95)


#CHI-SQUARE TEST FOR TRUE/FALSE CONDITIONS 
sq=chisq.test(merged$cluster,merged$heartCondition)
merged$vascular=factor(merged$vascular)
merged$BMI=(703*(merged$NonIdentifiableDemographics.json.patientWeightPounds/(merged$NonIdentifiableDemographics.json.patientHeightInches*merged$NonIdentifiableDemographics.json.patientHeightInches)))

#bicvals=c() 
#for(i in 2:20)
#{
#  fit=kmeans(data,i,nstart=10)
#  bicval=kmeansBIC(fit)
#  bicvals=c(bicvals,bicval)
#}

#PULL OUT PEOPLE W/ SIMILAR ACTIVITY AND CLUSTER BY STATE CHANGES
medium=merged[which(merged$stationary_day >=0.6 & merged$stationary_day<=0.75 & merged$stationary_end >=0.6 & merged$stationary_end <=0.75),]
medium_sub=data.frame(medium$changes_day,medium$changes_end)
for(i in 2:20)
{
  fit=kmeans(medium_sub,i,nstart=10)
  bicval=kmeansBIC(fit)
  bicvals=c(bicvals,bicval)
}

fit=kmeans(medium_sub,2,nstart=10)
medium$cluster=factor(fit$cluster)
p1<-ggplot(medium,aes(changes_day,changes_end,colour = cluster)) + geom_point(alpha=1/2) + xlab("Weekday")+ylab("Weekend")+ggtitle("Relative State Changes")

aov1<-aov(heartAgeDataBloodGlucose~cluster,data=medium)
tk<-TukeyHSD(aov1,conf.level=0.95)

aov1<-aov(heartAgeDataLdl~cluster,data=medium)
tk<-TukeyHSD(aov1,conf.level=0.95)

aov1<-aov(heartAgeDataHdl~cluster,data=medium)
tk<-TukeyHSD(aov1,conf.level=0.95)

aov1<-aov(heartAgeDataTotalCholesterol~cluster,data=medium)
tk<-TukeyHSD(aov1,conf.level=0.95)

aov1<-aov(bloodPressureInstruction~cluster,data=medium)
tk<-TukeyHSD(aov1,conf.level=0.95)


#DIET! 
aov1<-aov(fruit ~cluster,data=merged)
tk<-TukeyHSD(aov1,conf.level=0.95)

aov1<-aov(vegetable ~cluster,data=merged)
tk<-TukeyHSD(aov1,conf.level=0.95)

aov1<-aov(fish ~cluster,data=merged)
tk<-TukeyHSD(aov1,conf.level=0.95)

aov1<-aov(grains ~cluster,data=merged)
tk<-TukeyHSD(aov1,conf.level=0.95)

aov1<-aov(sugar_drinks ~cluster,data=merged)
tk<-TukeyHSD(aov1,conf.level=0.95)

aov1<-aov(sodium ~ cluster,data=merged)
tk<-TukeyHSD(aov1,conf.level=0.95)

#LIFE SATISFACTION! 
aov1<-aov(satisfiedwith_life ~ cluster,data=merged)
tk<-TukeyHSD(aov1,conf.level=0.95)


aov1<-aov(feel_worthwhile1 ~ cluster,data=merged)
tk<-TukeyHSD(aov1,conf.level=0.95)



#SELF-REPORTED VS. TRUTH (CORRELATION!!)