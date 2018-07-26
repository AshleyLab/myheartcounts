rm(list=ls())
options(warn=-1)
library(nlme)
library(car)
library(multcompView)
library(lsmeans)
library(rcompanion)


#ANALYSIS IN ACCORDANCE WITH REPEATED ANOVA MEASURES TUTORIAL HERE: 
#http://rcompanion.org/handbook/I_09.html 


#LOAD THE DATA 
#-------------------------------------------------------------------------------------------
data=data.frame(read.table(
  "~/sherlock/data/timeseries_v2/summary/sleep_healthkit_combined.txt.regression",
  header=TRUE,sep='\t',stringsAsFactors = FALSE))
#remove extreme outliers (i.e. < 4hours, > 15 hours)
data=data[data$Value <54000,]
data=data[data$Value > 7200,]
data$Value=data$Value/3600

data$Intervention=factor(data$Intervention,
                                   levels=c("Baseline",
                                   "APHClusterModule",
                                    "APHReadAHAWebsiteModule",
                                    "APHStandModule",
                                    "APHWalkModule",
                                    "InterventionGap",
                                    "PostIntervention"))
data$Subject=factor(data$Subject)



#---------------------------------------------------------------------------------
#ANALYZE SLEEP DURATION 
#determining autocorrelation in residuals -- this comes out to 0.336 
model.a = lme(Value ~ 
          Intervention + dayIndex + dayIndex*Intervention, 
          random = ~1 | Subject,data=data,
          control = lmeControl(opt = "optim"))
ACF(model.a,
    form = ~ 1 | Subject)
model = lme(Value ~ 
            Intervention  + dayIndex + Intervention*dayIndex, 
            random = ~1|Subject,
            correlation=corAR1(form = ~ 1 |Subject,value=0.1875543),
            data=data,
            control=lmeControl(opt="optim"))
Anova(model)
#TEST THE RANDOM EFFECTS OF THE MODEL 
model.fixed = gls(Value ~ Intervention +dayIndex+
                  Intervention*dayIndex,
                  data=data,
                  method="REML")
anova(model,
      model.fixed)
#POST HOC ANALYSIS  W/ TUKEY HSD 
marginal = lsmeans(model, ~ Intervention + dayIndex + Intervention*dayIndex)

cld_data=cld(marginal,
    alpha   = 0.05, 
    Letters = letters,     ### Use lower-case letters for .group
    adjust  = "tukey")     ###  Tukey-adjusted comparisons
plot(cld_data)
model_summary=summary(model)$tTable
#INTERACTION PLOT
Sum = groupwiseMean(Value ~ Intervention + dayIndex,
                    data   = data,
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
		theme_bw() +
    ylim(4,15)+
		theme(axis.title = element_text(face = "bold")) +
		ylab("Mean Hours of Sleep Per Day")

#HISTOGRAM OF RESIDUALS
x = residuals(model)
library(rcompanion)
plotNormalHistogram(x)
plot(fitted(model),
     residuals(model))
##########################################################################################################
#SLEEP QUALITY# 
data=data.frame(read.table(
  "~/sherlock/data/timeseries_v2/summary/sleep_healthkit_quality.txt",
  header=TRUE,sep='\t',stringsAsFactors = FALSE))
#remove extreme outliers (i.e. < 4hours, > 15 hours)
data=data[data$Value<1,]
data=data[data$Value>0.5,]

data$Intervention=factor(data$Intervention,
                         levels=c("Baseline",
                                  "APHClusterModule",
                                  "APHReadAHAWebsiteModule",
                                  "APHStandModule",
                                  "APHWalkModule",
                                  "InterventionGap",
                                  "PostIntervention"))
data$Subject=factor(data$Subject)



#---------------------------------------------------------------------------------
#ANALYZE SLEEP QUALITY 
#determining autocorrelation in residuals -- this comes out to 0.336 
model.a = lme(Value ~ 
                Intervention + dayIndex + dayIndex*Intervention, 
              random = ~1 | Subject,data=data,
              control = lmeControl(opt = "optim"))
ACF(model.a,
    form = ~ 1 | Subject)
model = lme(Value ~ 
              Intervention  + dayIndex + Intervention*dayIndex, 
            random = ~1|Subject,
            correlation=corAR1(form = ~ 1 |Subject,value= -0.143928597),
            data=data,
            control=lmeControl(opt="optim"))
Anova(model)
#TEST THE RANDOM EFFECTS OF THE MODEL 
model.fixed = gls(Value ~ Intervention +dayIndex+
                    Intervention*dayIndex,
                  data=data,
                  method="REML")
anova(model,
      model.fixed)
#POST HOC ANALYSIS  W/ TUKEY HSD 
marginal = lsmeans(model, ~ Intervention + dayIndex + Intervention*dayIndex)

cld_data=cld(marginal,
             alpha   = 0.05, 
             Letters = letters,     ### Use lower-case letters for .group
             adjust  = "tukey")     ###  Tukey-adjusted comparisons
plot(cld_data, xlab= "Hours Asleep / Hours In Bed", ylab="Intervention: Days In Study")
model_summary=summary(model)$tTable
#INTERACTION PLOT
Sum = groupwiseMean(Value ~ Intervention + dayIndex,
                    data   = data,
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
  theme_bw() +
  ylim(0,1)+
  theme(axis.title = element_text(face = "bold")) +
  ylab("Mean Hours of Sleep Per Day")

#HISTOGRAM OF RESIDUALS
x = residuals(model)
library(rcompanion)
plotNormalHistogram(x)
plot(fitted(model),
     residuals(model))
