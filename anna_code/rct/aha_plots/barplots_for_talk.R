rm(list=ls())
library(ggplot2)
baseline=read.table("baseline.csv",header=TRUE,sep='\t')
effects=read.table("effect_size.csv",header=TRUE,sep='\t')
effects_phone=effects[effects$Device=="Smartphone",]
phone_v_watch=read.table("phone_v_watch.csv",header=TRUE,sep='\t')
p1=ggplot(data=baseline,
       aes(x=baseline$Group,
           y=baseline$Steps))+
  geom_bar(stat='identity')+
  theme_bw(20)+
  geom_errorbar(aes(ymin=baseline$Steps-baseline$SE,ymax=baseline$Steps+baseline$SE))+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))+
  xlab("Group")+
  ylab("Baseline Mean Daily Steps")

p2=ggplot(data=effects_phone,
          aes(x=effects_phone$Intervention,
              y=effects_phone$Steps))+
  geom_bar(stat='identity',fill="#1b9e77")+
  theme_bw(20)+
  geom_errorbar(aes(ymin=effects_phone$Steps-effects_phone$SE,
                    ymax=effects_phone$Steps+effects_phone$SE))+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))+
  xlab("Interventions")+
  ylab("Effect Size (Daily Steps)")


p3=ggplot(data=effects,
          aes(x=effects$Intervention,
              y=effects$Steps,
              ymin=effects$Steps-effects$SE,
              ymax=effects$Steps+effects$SE,
              group=effects$Device,
              fill=effects$Device))+
  geom_bar(stat='identity',position = "dodge")+
  theme_bw(20)+
  geom_errorbar(position=position_dodge(width=0.9))+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))+
  xlab("Interventions")+
  ylab("Effect Size (Daily Steps)")+
  scale_fill_manual(values=c("#1b9e77","#d95f02"),name="Device")

p4=ggplot(data=phone_v_watch,
          aes(x=phone_v_watch$Intervention,
              y=phone_v_watch$Steps,
              ymin=phone_v_watch$Steps-phone_v_watch$SE,
              ymax=phone_v_watch$Steps+phone_v_watch$SE,
              group=phone_v_watch$Device,
              fill=phone_v_watch$Device))+
  geom_bar(stat='identity',position = "dodge")+
  theme_bw(20)+
  geom_errorbar(position=position_dodge(width=0.9))+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))+
  xlab("Interventions")+
  ylab("Effect Size (Daily Steps)")+
  scale_fill_manual(values=c("#1b9e77","#d95f02"),name="Device")

