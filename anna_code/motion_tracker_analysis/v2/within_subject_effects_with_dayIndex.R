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


#LOAD THE DATA 
#-------------------------------------------------------------------------------------------
motion_tracker=data.frame(read.table(
  "~/sherlock/data/timeseries_v2/summary/motion_tracker_combined.filtered.txt.regression",
  header=TRUE,sep='\t',stringsAsFactors = FALSE))
healthkit_steps=data.frame(read.table(
  "~/sherlock/data/timeseries_v2/summary/healthkit_combined.stepcount.txt.regression",
  header=TRUE,sep='\t',stringsAsFactors = FALSE))
healthkit_distance=data.frame(read.table(
  "~/sherlock/data/timeseries_v2/summary/healthkit_combined.distance.txt.regression",
  header=TRUE,sep='\t',stringsAsFactors = FALSE))

#Remove any step counts greater than 20k and distance walked > 25k meters 
healthkit_steps=healthkit_steps[healthkit_steps$Value<20000,]
healthkit_distance=healthkit_distance[healthkit_distance$Value<25000,]

motion_tracker$Intervention=factor(motion_tracker$Intervention,
                                   levels=c("Baseline",
                                   "Cluster",
                                    "ReadAHAWebsite",
                                    "Stand",
                                    "Walk",
                                    "InterventionGap",
                                    "PostIntervention"))
healthkit_steps=healthkit_steps[healthkit_steps$Intervention %in% c("Baseline",
                                                                  "Cluster",
                                                                  "ReadAHAWebsite",
                                                                  "Stand",
                                                                  "Walk"),]
healthkit_steps$Intervention=factor(healthkit_steps$Intervention,
                                    levels=c("Baseline",
                                    "Cluster",
                                    "ReadAHAWebsite",
                                    "Stand",
                                    "Walk"))
healthkit_steps=healthkit_steps[healthkit_steps$WatchVsPhone=="phone",]

motion_tracker$Intervention=factor(motion_tracker$Intervention,
                                   levels=c("Baseline",
                                   "ClusterModule",
                                   "ReadAHAWebsiteModule",
                                   "StandModule",
                                   "WalkModule",
                                   "InterventionGap",
                                   "PostIntervention"))
healthkit_steps$Subject=factor(healthkit_steps$Subject)
healthkit_distance$Subject=factor(healthkit_distance$Subject)
motion_tracker$Subject=factor(motion_tracker$Subject)

#get active fractions & minutes for motion tracker 
stationary_subset=motion_tracker[motion_tracker$Activity=="stationary",]
walking_subset=motion_tracker[motion_tracker$Activity=="walking",]
active_subset=motion_tracker[motion_tracker$Activity %in% c("running","walking","cycling"),]
automotive_subset=motion_tracker[motion_tracker$Activity=="automotive",]
exercise_subset=motion_tracker[motion_tracker$Activity %in% c("running","cycling"),]



#---------------------------------------------------------------------------------
#ANALYZE HEALTHKIT STEPS 
#determining autocorrelation in residuals -- this comes out to 0.336 
#model.a = lme(Value ~ Intervention +WeekIndex, 
#          random = ~1 | Subject,data=healthkit_steps,
#          control = lmeControl(opt = "optim"))
#ACF(model.a,
#    form = ~ 1 | Subject)

#estimate correlation at same time as fit model 

#week index --reduce parameters. 
#add quadratic term 
#remove interaction terms 
#intent to treat ? 
# use last received intervention  & last assigned intervention ; but causes collinearity issues 
# just the 4 
#Add indicator variable if person is watch + phone vs just phone 

#use the default structure assuming consistent behavior 

healthkit_steps$WeekIndex=ceiling(healthkit_steps$dayIndex/7) 
model = lme(Value ~ 
              Intervention  + WeekIndex + WeekIndex**2, 
            random = ~1|Subject,
            data=healthkit_steps,
            control=lmeControl(opt="optim"))

model = lme(Value ~ 
            Intervention + WatchVsPhone + dayIndex + Intervention*dayIndex
            +Intervention*WatchVsPhone+dayIndex*WatchVsPhone, 
            random = ~1|Subject,
            correlation=corAR1(form = ~ 1 |Subject,value=0.336),
            data=healthkit_steps,
            control=lmeControl(opt="optim"))
Anova(model)
#TEST THE RANDOM EFFECTS OF THE MODEL 
model.fixed = gls(Value ~ Intervention +dayIndex+
                  Intervention*dayIndex+Intervention*WatchVsPhone+dayIndex*WatchVsPhone,
                  data=healthkit_steps,
                  method="REML")
anova(model,
      model.fixed)
#POST HOC ANALYSIS  W/ TUKEY HSD 
marginal = lsmeans(model, ~ Intervention + WeekIndex )

plot(cld(marginal,
    alpha   = 0.05, 
    Letters = letters,     ### Use lower-case letters for .group
    adjust  = "tukey"))     ###  Tukey-adjusted comparisons

#INTERACTION PLOT
Sum = groupwiseMean(Value ~ Intervention + dayIndex,
                    data   = healthkit_steps,
		    conf   = 0.95,
		    digits = 3,
		    traditional = TRUE,
		    percentile  = FALSE)
library(ggplot2)

pd = position_dodge(.2)

ggplot(Sum, aes(x =    dayIndex,
                y =    Mean,
	        color = Intervention)) +
		geom_errorbar(aes(ymin=Trad.lower,
		ymax=Trad.upper),
		width=.2, size=0.7, position=pd) +
		geom_point(shape=15, size=4, position=pd) +
    ylim(c(0,20000))+
		theme_bw() +
		theme(axis.title = element_text(face = "bold")) +
		ylab("Mean Steps per Day")

#HISTOGRAM OF RESIDUALS
x = residuals(model)
library(rcompanion)
plotNormalHistogram(x)
plot(fitted(model),
     residuals(model))
#---------------------------------------------------------------------------------
#REPEAT THE ABOVE ANALYSIS FOR HEALTHKIT DISTANCE 
model.a = lme(Value ~ 
                Intervention + WatchVsPhone+dayIndex + dayIndex*Intervention, 
              random = ~1 | Subject,data=healthkit_distance,
              control = lmeControl(opt = "optim"))
ACF(model.a,
    form = ~ 1 | Subject)
model = lme(Value ~ 
              Intervention + WatchVsPhone + dayIndex + Intervention*dayIndex
            +Intervention*WatchVsPhone+dayIndex*WatchVsPhone, 
            random = ~1|Subject,
            correlation=corAR1(form = ~ 1 |Subject,value=0.314),
            data=healthkit_distance,
            control=lmeControl(opt="optim"))
Anova(model)
#TEST THE RANDOM EFFECTS OF THE MODEL 
model.fixed = gls(Value ~ Intervention + WatchVsPhone+dayIndex+
                    Intervention*dayIndex+Intervention*WatchVsPhone+dayIndex*WatchVsPhone,
                  data=healthkit_distance,
                  method="REML")
anova(model,
      model.fixed)
#POST HOC ANALYSIS  W/ TUKEY HSD 
marginal = lsmeans(model, ~ Intervention + WeekIndex )
plot(cld(marginal,
    alpha   = 0.05, 
    Letters = letters,     ### Use lower-case letters for .group
    adjust  = "tukey"))     ###  Tukey-adjusted comparisons
#INTERACTION PLOT
Sum = groupwiseMean(Value ~ Intervention + dayIndex,
                    data   = healthkit_distance,
                    conf   = 0.95,
                    digits = 3,
                    traditional = TRUE,
                    percentile  = FALSE)
pd = position_dodge(.2)
ggplot(Sum, aes(x =    dayIndex,
                y =    Mean,
                color = Intervention)) +
  geom_errorbar(aes(ymin=Trad.lower,
                    ymax=Trad.upper),
                width=.2, size=0.7, position=pd) +
  geom_point(shape=15, size=4, position=pd) +
  ylim(c(0,20000))+
  theme_bw() +
  theme(axis.title = element_text(face = "bold")) +
  ylab("Mean Distance (m) per Day")

#HISTOGRAM OF RESIDUALS
x = residuals(model)
plotNormalHistogram(x)
plot(fitted(model),
     residuals(model))
#---------------------------------------------------------------------------------
#REPEAT THE ANALYSIS FOR MOTION TRACKER ACTIVE MINUTES 
model.a = lme(Duration_in_Minutes ~ 
                Intervention +dayIndex + dayIndex*Intervention, 
              random = ~1 | Subject,data=active_subset,
              control = lmeControl(opt = "optim"))
ACF(model.a,
    form = ~ 1 | Subject)
model = lme(Duration_in_Minutes ~ 
              Intervention + dayIndex + Intervention*dayIndex, 
            random = ~1|Subject,
            correlation=corAR1(form = ~ 1 |Subject,value= -0.093452563),
            data=active_subset,
            control=lmeControl(opt="optim"))
Anova(model)
#TEST THE RANDOM EFFECTS OF THE MODEL 
model.fixed = gls(Duration_in_Minutes ~ Intervention + Intervention*dayIndex,
                  data=active_subset,
                  method="REML")
anova(model,
      model.fixed)
#POST HOC ANALYSIS  W/ TUKEY HSD 
marginal = lsmeans(model, ~ Intervention + dayIndex + Intervention*dayIndex)
cld(marginal,
    alpha   = 0.05, 
    Letters = letters,     ### Use lower-case letters for .group
    adjust  = "tukey")     ###  Tukey-adjusted comparisons
#INTERACTION PLOT
Sum = groupwiseMean(Duration_in_Minutes ~ Intervention + dayIndex,
                    data   = active_subset,
                    conf   = 0.95,
                    digits = 3,
                    traditional = TRUE,
                    percentile  = FALSE)
pd = position_dodge(.2)
ggplot(Sum, aes(x =    dayIndex,
                y =    Mean,
                color = Intervention)) +
  geom_errorbar(aes(ymin=Trad.lower,
                    ymax=Trad.upper),
                width=.2, size=0.7, position=pd) +
  geom_point(shape=15, size=4, position=pd) +
  ylim(c(0,240))+
  theme_bw() +
  theme(axis.title = element_text(face = "bold")) +
  ylab("Mean Active Minutes per Day")

#HISTOGRAM OF RESIDUALS
x = residuals(model)
plotNormalHistogram(x)
plot(fitted(model),
     residuals(model))
