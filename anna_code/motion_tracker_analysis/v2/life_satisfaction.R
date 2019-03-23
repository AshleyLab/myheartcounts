rm(list=ls())
options(warn=-1)
library(nlme)
library(car)
library(multcompView)
library(lsmeans)
library(rcompanion)
library(ggplot2)

data=read.table("satisfaction_with_interventions.txt",header=TRUE,sep='\t')
data$Value=data$Worthwhile
data$Worthwhile=NULL
data$Happy=NULL
data$Worried=NULL
data$Depressed=NULL
data$Satisfied=NULL
data=data[data$Value>=0,]
data=data[data$Value<=10,]
data=na.omit(data)
data$WeekIndex=data$dayIndex/7
model = lme(Value ~ 
              Intervention  + WeekIndex, 
            random = ~1|Subject,
            data=data)
Anova(model)
marginal = lsmeans(model, ~ Intervention + WeekIndex )

cld_data=cld(marginal,
             alpha   = 0.05, 
             Letters = letters,     ### Use lower-case letters for .group
             adjust  = "tukey")     ###  Tukey-adjusted comparisons
plot(cld_data)
model_summary=summary(model)$tTable
