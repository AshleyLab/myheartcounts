rm(list=ls())
options(warn=-1)
library(nlme)
library(car)
library(multcomp)
library(multcompView)
library(lsmeans)
library(rcompanion)
library(sjPlot)
library(dplyr)

healthkit_steps=data.frame(read.table(
  "health_kit_combined.steps.txt.regression",
  header=TRUE,sep='\t',stringsAsFactors = FALSE))

#Remove any step counts greater than 20k  
healthkit_steps=healthkit_steps[healthkit_steps$Value<20000,]

#restrict analysis to person-days that fall into one of study phases
phases=c("baseline","cluster","read_aha","stand","walk")
healthkit_steps=healthkit_steps[healthkit_steps$ABTest %in% phases,]
healthkit_steps$ABTest=factor(healthkit_steps$ABTest,levels=phases)

#phone only
healthkit_steps=healthkit_steps[healthkit_steps$WatchVsPhone=="phone",]

#subjects are random effects, generate factor from string
healthkit_steps$Subject=factor(healthkit_steps$Subject)

#keep track of weekIndex in addition to dayIndex
healthkit_steps$WeekIndex=ceiling(healthkit_steps$dayIndex/7) 


library(ggplot2)
data=healthkit_steps[healthkit_steps$appVersion!="NONE",]
ggplot(data=data,aes(y=data$dayIndex,x=data$appVersion))+
  geom_boxplot()+
  xlab("App Version")+
  ylab("Day Index")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
