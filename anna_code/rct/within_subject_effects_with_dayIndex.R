rm(list=ls())
options(warn=-1)
library(nlme)
library(car)
library(multcompView)
library(lsmeans)
library(rcompanion)

#STATA & SAS 

#ANALYSIS IN ACCORDANCE WITH REPEATED ANOVA MEASURES TUTORIAL HERE: 
#http://rcompanion.org/handbook/I_09.html 

#suggestions from Laura:
#week index --reduce parameters. -- done, see below 
#add quadratic term -- done, see below 

#remove interaction terms --done 
# intent to treat -- yes, use the ABTest value --done 
# use last received intervention  & last assigned intervention ; but causes collinearity issues  -- done 
# Add indicator variable if person is watch + phone vs just phone 


#LOAD THE DATA 
#-------------------------------------------------------------------------------------------
healthkit_steps=data.frame(read.table(
  "health_kit_combined.steps.txt.regression",
  header=TRUE,sep='\t',stringsAsFactors = FALSE))
healthkit_distance=data.frame(read.table(
  "health_kit_combined.distance.txt.regression",
  header=TRUE,sep='\t',stringsAsFactors = FALSE))

#Remove any step counts greater than 20k and distance walked > 25k meters 
healthkit_steps=healthkit_steps[healthkit_steps$Value<20000,]
healthkit_distance=healthkit_distance[healthkit_distance$Value<25000,]

healthkit_steps=healthkit_steps[healthkit_steps$ABTest %in% c("baseline",
                                                                  "cluster",
                                                                  "read_aha",
                                                                  "stand",
                                                                  "walk"),]
healthkit_distance=healthkit_distance[healthkit_distance$ABTest %in% c("baseline",
                                                                    "cluster",
                                                                    "read_aha",
                                                                    "stand",
                                                                    "walk"),]

healthkit_steps$ABTest=factor(healthkit_steps$ABTest,
                                    levels=c("baseline",
                                    "cluster",
                                    "read_aha",
                                    "stand",
                                    "walk"))
healthkit_distance$ABTest=factor(healthkit_distance$ABTest,
                                    levels=c("baseline",
                                             "cluster",
                                             "read_aha",
                                             "stand",
                                             "walk"))

healthkit_steps=healthkit_steps[healthkit_steps$WatchVsPhone=="phone",]
healthkit_distance=healthkit_distance[healthkit_distance$WatchVsPhone=="phone",]

healthkit_steps$Subject=factor(healthkit_steps$Subject)
healthkit_distance$Subject=factor(healthkit_distance$Subject)

healthkit_distance$dayIndex=as.numeric(healthkit_distance$dayIndex)
healthkit_steps$WeekIndex=ceiling(healthkit_steps$dayIndex/7) 
healthkit_distance$WeekIndex=ceiling(healthkit_distance$dayIndex/7)

model = lme(Value ~ 
              ABTest  + WeekIndex + WeekIndex**2, 
            random = ~1|Subject,
            data=healthkit_steps,
            control=lmeControl(opt="optim"))
Anova(model)
marginal = lsmeans(model, ~ ABTest + WeekIndex )

plot(cld(marginal,
    alpha   = 0.05, 
    Letters = letters,     ### Use lower-case letters for .group
    adjust  = "tukey"))     ###  Tukey-adjusted comparisons
#HISTOGRAM OF RESIDUALS
x = residuals(model)
library(rcompanion)
plotNormalHistogram(x)
plot(fitted(model),
     residuals(model))
#########################################################################
#REPEAT ANALYSIS FOR DISTANCE OUTCOME 
model = lme(Value ~ 
              ABTest  + WeekIndex + WeekIndex**2, 
            random = ~1|Subject,
            data=healthkit_distance,
            control=lmeControl(opt="optim"))
Anova(model)
marginal = lsmeans(model, ~ ABTest + WeekIndex )

plot(cld(marginal,
         alpha   = 0.05, 
         Letters = letters,     ### Use lower-case letters for .group
         adjust  = "tukey"))     ###  Tukey-adjusted comparisons
#HISTOGRAM OF RESIDUALS
x = residuals(model)
library(rcompanion)
plotNormalHistogram(x)
plot(fitted(model),
     residuals(model))