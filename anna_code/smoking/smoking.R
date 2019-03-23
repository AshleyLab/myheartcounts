rm(list=ls())
library(ggplot2)
library(nlme)
library(car)
library(multcompView)
library(lsmeans)
library(rcompanion)

data=read.table("smoking_vs_hk_steps.tsv",header=TRUE,sep='\t',stringsAsFactors = FALSE)
data$Age=as.numeric(as.character(data$Age))
data=data[data$Age>40,]
data=na.omit(data)
data=data[data$MeanDailyHkSteps<=50000,]
ggplot(data=data,
       aes(x=data$SmokingStatus,y=data$MeanDailyHkSteps))+
  geom_boxplot()+
  xlab("Are you currently smoking cigarettes?")+
  ylab("Mean Daily Steps, from HealthKit")+
  ggtitle("N Smokers=151, N Non-Smokers=3475")+
  theme_bw(15)

model = lme(MeanDailyHkSteps ~ SmokingStatus, 
            random = ~1|Subject,
            data=data,
            control=lmeControl(opt="optim"))
marginal = lsmeans(model, ~ SmokingStatus )
print(summary(model))

ggplot(data,aes(x=data$Age,group=data$SmokingStatus,fill=data$SmokingStatus))+
  geom_histogram(position="stack",stat="count")+
  ggtitle("Smokers by Age, N Smokers=151, N non-smokers=3471")+
  theme_bw(20)