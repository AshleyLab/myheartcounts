rm(list=ls())
library(data.table) 
library(ggplot2)
load('hr_walk.bin')
load('hr_rest.bin')
load('clustered_activity_state.bin')
activity_state_hr=data.frame(read.table("HR_for_Activity_State_MERGED.tsv",sep='\t',header=T,stringsAsFactors = FALSE))
nontime=data.frame(read.table("NonTimeSeries.txt",header=T,sep='\t',row.names=1))
###########################

m=merge(activity_state_hr,nontime,by.x="Subject",by.y="row.names")
m$walk=60*m$walk
m$run=60*m$run
w=merge(nontime,hr_walk,by.x="row.names",by.y="row.names")
r=merge(nontime,hr_rest,by.x="row.names",by.y="row.names")

#attach(m)
#f=glm(heartAgeDataDiabetes~walk,family=binomial)
#hr_walk_subset=subset(hr_walk,select=c("Max","Min","Var","speed","last_min_hr"))
#km=kmeans(hr_walk_subset,2)
ma=merge(merged,activity_state_hr,by.x="subject",by.y="Subject",all=TRUE)
#p<-ggplot(ma,aes(cluster,walk))+geom_boxplot()+theme_bw(20)+xlab("Activity Cluster")+ylab("Walking Heart Rate (bpm)")+scale_x_discrete(labels=c("Active","State Changer","Week. War.","Weekday Active","Couch Pot.","Couch Pot.","NA"))
#p<-ggplot(m,aes(factor(decade),walk))+geom_boxplot()+theme_bw(20)+xlab("Decade of Age")+ylab("Walking Heart Rate (bpm)")+scale_x_discrete(labels=c("Stroke","TIA","Stenosis","Stent","Peripheral","Aneurysm","None","NA"))

p<-ggplot(m,aes(factor(heartCondition),walk))+geom_boxplot()+theme_bw(20)+xlab("Heart Condition")+ylab("Walking Heart Rate (bpm)")
#p<-ggplot(full,aes(factor(heartCondition),delta1.y))+geom_boxplot()+theme_bw(20)+xlab("Heart Condition")+ylab("First Minute Recovery Heart Rate (delta bpm)")+scale_x_discrete(labels=c("Heart Attack","Bypass","Stent","Afib","Cong. def.","None","NA"))
#p<-ggplot(full,aes(factor(satisfiedwith_life),Min.x))+geom_boxplot()+theme_bw(20)+xlab("Heart Condition")+ylab("First Minute Recovery Heart Rate (delta bpm)")
#p<-ggplot(full,aes(factor(feel_worthwhile1),Max.x))+geom_boxplot()+theme_bw(20)+xlab("Feel worthwhile (1-10)")+ylab("Max HR 6 Minute Walk")
#p<-ggplot(full,aes(factor(feel_worthwhile2),Var.x))+geom_boxplot()+theme_bw(20)+xlab("Feel happy (1-10)")+ylab("Var HR 6 Minute Walk")
#p<-ggplot(full,aes(factor(feel_worthwhile3),speed.x))+geom_boxplot()+theme_bw(20)+xlab("Feel worried (1-10)")+ylab("Speed")
#p<-ggplot(rws,aes(factor(cluster),speed.x))+geom_boxplot()+theme_bw(20)+xlab("Cluster")+ylab("Speed")

varvals=data.frame(read.table("HR_Var.txt",sep='\t',header=F,stringsAsFactors = FALSE))
varvals$V2=sqrt(varvals$V2)*60
firstvals=data.frame(read.table("HR_First.txt",sep='\t',header=F,stringsAsFactors = FALSE))

par(mfrow=c(4,1))
hist(firstvals$V2,30,xlim=c(0,200),main="First HR of the Day (Before Noon)",xlab=NULL)
hist(activity_state_hr$walk*60,30,xlim=c(0,200),main="Mean Walking HR",xlab=NULL)
hist(activity_state_hr$run*60,30,xlim=c(0,200),main="Mean Running HR",xlab=NULL)
hist(varvals$V2,30,main="HR Standard Dev (bpm) ",xlab=NULL)

p<-ggplot(varvals,aes(factor(heart_disease),V2))+geom_boxplot()+theme_bw(20)+xlab("Heart Disease")+ylab("HR Variance (bpm)")+scale_x_discrete(labels=c("Heart Attack","Bypass","Stenosis","Stent","Angina","High Ca","CHF","Afib","Cong. def.","None","NA"))


p<-ggplot(ma,aes(cluster,run))+geom_boxplot()+theme_bw(20)+xlab("Activity Cluster")+ylab("Running Heart Rate (bpm)")+scale_x_discrete(labels=c("Active","State Changer","Week. War.","Weekday Active","Couch Pot.","Couch Pot.","NA"))


##GET THE EFFECT SIZES## 
nontime$V1=row.names(nontime)
df=merge(nontime,varvals,by="V1")
df$heartAgeDataHypertension=factor(df$heartAgeDataHypertension)
aov1=aov(V2~heartAgeDataHypertension,data=df)
tk=TukeyHSD(aov1)

df$vascular=factor(df$vascular)
aov1=aov(V2~vascular,data=df)
tk=TukeyHSD(aov1)


df$jointProblem=factor(df$jointProblem)
aov1=aov(V2~jointProblem,data=df)
tk=TukeyHSD(aov1)

df$chestPain=factor(df$chestPain)
aov1=aov(V2~chestPain,data=df)
tk=TukeyHSD(aov1)

df$heart_disease=factor(df$heart_disease)
aov1=aov(V2~heart_disease,data=df)
tk=TukeyHSD(aov1)