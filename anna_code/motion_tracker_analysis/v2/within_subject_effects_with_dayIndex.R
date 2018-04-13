rm(list=ls())

#ANALYSIS IN ACCORDANCE WITH REPEATED ANOVA MEASURES TUTORIAL HERE: http://rcompanion.org/handbook/I_09.html 

motion_tracker=data.frame(read.table("~/sherlock/data/timeseries_v2/summary/motion_tracker_combined.filtered.txt.regression",header=TRUE,sep='\t',stringsAsFactors = FALSE))
healthkit_steps=data.frame(read.table("~/sherlock/data/timeseries_v2/summary/healthkit_combined.stepcount.txt.regression",header=TRUE,sep='\t',stringsAsFactors = FALSE))

#Remove any step counts greater than 20k and distance walked > 25k meters 
healthkit_steps=healthkit_steps[healthkit_steps$Value<20000,]
healthkit_distance=data.frame(read.table("~/sherlock/data/timeseries_v2/summary/healthkit_combined.distance.txt.regression",header=TRUE,sep='\t',stringsAsFactors = FALSE))
helathkit_distance=healthkit_distance[healthkit_distance$Value<25000,]

motion_tracker$Intervention=factor(motion_tracker$Intervention,levels=c("Baseline",
                                                                               "APHClusterModule",
                                                                               "APHReadAHAWebsiteModule",
                                                                               "APHStandModule",
                                                                               "APHWalkModule",
                                                                               "InterventionGap",
                                                                               "PostIntervention"))
healthkit_steps$Intervention=factor(healthkit_steps$Intervention,levels=c("Baseline",
                                                                          "APHClusterModule",
                                                                          "APHReadAHAWebsiteModule",
                                                                          "APHStandModule",
                                                                          "APHWalkModule",
                                                                          "InterventionGap",
                                                                          "PostIntervention"))

motion_tracker$Intervention=factor(motion_tracker$Intervention,levels=c("Baseline",
                                                                        "APHClusterModule",
                                                                        "APHReadAHAWebsiteModule",
                                                                        "APHStandModule",
                                                                        "APHWalkModule",
                                                                        "InterventionGap",
                                                                        "PostIntervention"))
healthkit_steps$Subject=factor(healthkit_steps$Subject)
healthkit_distance$Subject=factor(healthkit_distance$Subject)
motion_tracker$Subject=factor(motion_tracker$Subject)



library(nlme)
#determining autocorrelation in residuals -- this comes out to 0.336 
model.a = lme(Value ~ Intervention + WatchVsPhone+dayIndex + dayIndex*Intervention, random = ~1 | Subject,data=healthkit_steps,
              control = lmeControl(opt = "optim"))
ACF(model.a,
    form = ~ 1 | Subject)

model = lme(Value ~ Intervention + WatchVsPhone + dayIndex + Intervention*dayIndex+Intervention*WatchVsPhone+dayIndex*WatchVsPhone, 
            random = ~1|Subject,
            correlation=corAR1(form = ~ 1 |Subject,value=0.336),
            data=healthkit_steps,
            control=lmeControl(opt="optim"))

library(car)
Anova(model)
#TEST THE RANDOM EFFECTS OF THE MODEL 
model.fixed = gls(Value ~ Intervention + WatchVsPhone+dayIndex+Intervention*dayIndex+Intervention*WatchVsPhone+dayIndex*WatchVsPhone,
                  data=healthkit_steps,
                  method="REML")
anova(model,
      model.fixed)


#POST HOC ANALYSIS  W/ TUKEY HSD 
library(multcompView)
library(lsmeans)
marginal = lsmeans(model, ~ Intervention + dayIndex + Intervention*dayIndex+WatchVsPhone)

cld(marginal,
    alpha   = 0.05, 
    Letters = letters,     ### Use lower-case letters for .group
    adjust  = "tukey")     ###  Tukey-adjusted comparisons


#INTERACTION PLOT

library(rcompanion)

Sum = groupwiseMean(Value ~ Intervention + dayIndex + WatchVsPhone,
                    data   = healthkit_steps,
		    conf   = 0.95,
		    digits = 3,
		    traditional = FALSE,
		    percentile  = TRUE)
library(ggplot2)

pd = position_dodge(.2)

ggplot(Sum, aes(x =    dayIndex,
                y =    Value,
	        color = Intervention)) +
		geom_errorbar(aes(ymin=Percentile.lower,
		ymax=Percentile.upper),
		width=.2, size=0.7, position=pd) +
		geom_point(shape=15, size=4, position=pd) +
		theme_bw() +
		theme(axis.title = element_text(face = "bold")) +
		ylab("Mean calories per day")

#HISTOGRAM OF RESIDUALS
x = residuals(model)
library(rcompanion)
plotNormalHistogram(x)
plot(fitted(model),
     residuals(model))