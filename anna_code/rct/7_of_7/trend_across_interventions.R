rm(list=ls())
data=read.table("all_four_interventions.txt",header=TRUE,sep='\t')
phone=data[data$WatchVsPhone=="phone",]
watch=data[data$WatchVsPhone=="watch",]
library(ggplot2)
ggplot(data=phone,
     aes(x=phone$dayIndex,
         y=phone$Value))+
  geom_point(alpha=0.1)+
  xlab("Days Since Coaching Start")+
  ylab("Step Count from iPhone")
#keep track of weekIndex in addition to dayIndex
phone$WeekIndex=ceiling(phone$dayIndex/7) 

model = lme(Value ~ ABTest +weekIndex, 
            random = ~1|Subject,
            data=healthkit_steps,
            control=lmeControl(opt="optim"))
marginal = lsmeans(model, ~ ABTest +dayIndex  )
print(summary(model))
print("marginal:")
print(marginal)
print("Tukey HSD:")
summary(glht(model,linfct=mcp(ABTest="Tukey")))

plot(cld(marginal,
         alpha   = 0.05, 
         Letters = letters,     ### Use lower-case letters for .group
         adjust  = "tukey"),xlim=c(2000,5000))
