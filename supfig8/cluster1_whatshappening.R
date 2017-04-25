rm(list=ls())
library(ggplot2)
library(reshape2)
load("motion_tracker_merged_df")
load("clustered_activity_state.bin")

#GET THE FIELDS OF INTEREST! 
proportions=subset(merged_df,select=c("Walking_weekday","Walking_weekend", "Running_weekday","Running_weekend","Cycling_weekday","Cycling_weekend","Stationary_weekday","Stationary_weekend","Automotive_weekday","Automotive_weekend","Unknown_weekday","Unknown_weekend"))
clusterinfo=subset(merged,select=c("subject","cluster","work","atwork","phys_activity","moderate_act","vigorous_act"))
data=merge(clusterinfo,proportions,by.x="subject",by.y="row.names",all=TRUE)

workers=table(data$work,data$cluster)
workersnorm=workers
workersnorm["TRUE",]=workers["TRUE",]/colSums(workers)
workersnorm["FALSE",]=workers["FALSE",]/colSums(workers)
barplot(workersnorm,legend.text=c("Do not work","Work"),xlab="Cluster",ylab="Fraction of subjects")

jobtype=table(data$atwork,data$cluster)
jobtypenorm=jobtype
cs=colSums(jobtype)
jobtypenorm["1",]=jobtype["1",]/cs
jobtypenorm["2",]=jobtype["2",]/cs
jobtypenorm["3",]=jobtype["3",]/cs
jobtypenorm["4",]=jobtype["4",]/cs
jobtypenorm=as.data.frame(jobtypenorm)
ggplot(jobtypenorm,aes(factor(Var2),Freq,fill=Var1))+geom_bar(stat="identity",position="dodge")+scale_fill_brewer(palette="Set1")+theme_bw(20)+xlab("Cluster")+ylab("Fraction of Subjects")+scale_fill_discrete(name="Job Activity Level",
                                                                                                                                                                                                                breaks=c("1", "2", "3","4"),
                                                                                                                                                                                                                labels=c("Sitting/Standing", "Walking", "Moderate Exertion","Hard Labor"))

ggplot(data,aes(cluster,phys_activity))+geom_boxplot()+theme_bw(20) +xlab("Cluster") +ylab("Level of Physical Activity (Leisure)")                                                                                                                                         
ggplot(data,aes(cluster,moderate_act))+geom_boxplot()+theme_bw(20) +xlab("Cluster") +ylab("Minutes per week")+title("Moderate Activity")+ylim(0,500)                                                                                                                   
ggplot(data,aes(cluster,vigorous_act))+geom_boxplot()+theme_bw(20) +xlab("Cluster") +ylab("Minutes per week")+title("Vigorous Activity")+ylim(0,500)                                                                                                                                         
ggplot(data,aes(cluster,vigorous_act))+geom_boxplot()+theme_bw(20) +xlab("Cluster") +ylab("Minutes per week")+title("Vigorous Activity")+ylim(0,500)                                                                                                                                         

active_subset=subset(data,select=c("cluster","Stationary_weekday","Stationary_weekend","Automotive_weekday","Automotive_weekend","Walking_weekday","Walking_weekend","Running_weekday","Running_weekend","Cycling_weekday","Cycling_weekend"))
active_subset=melt(active_subset,id="cluster")
clus1=active_subset[which(active_subset$cluster %in% 1),]
clus2=active_subset[which(active_subset$cluster %in% 2),]
clus3=active_subset[which(active_subset$cluster %in% 3),]
clus4=active_subset[which(active_subset$cluster %in% 4),]
clus5=active_subset[which(active_subset$cluster %in% 5),]
clus6=active_subset[which(active_subset$cluster %in% 6),]
ggplot(clus1,aes(variable,value))+geom_boxplot()+theme_bw(20)+theme(axis.text.x = element_text(angle = 90, hjust = 1))+xlab('Activity State')+ylab("Proportion of Day")+ylim(c(0,0.5))
ggplot(clus2,aes(variable,value))+geom_boxplot()+theme_bw(20)+theme(axis.text.x = element_text(angle = 90, hjust = 1))+xlab('Activity State')+ylab("Proportion of Day")+ylim(c(0,0.5))
ggplot(clus3,aes(variable,value))+geom_boxplot()+theme_bw(20)+theme(axis.text.x = element_text(angle = 90, hjust = 1))+xlab('Activity State')+ylab("Proportion of Day")+ylim(c(0,0.5))
ggplot(clus4,aes(variable,value))+geom_boxplot()+theme_bw(20)+theme(axis.text.x = element_text(angle = 90, hjust = 1))+xlab('Activity State')+ylab("Proportion of Day")+ylim(c(0,0.5))
ggplot(clus5,aes(variable,value))+geom_boxplot()+theme_bw(20)+theme(axis.text.x = element_text(angle = 90, hjust = 1))+xlab('Activity State')+ylab("Proportion of Day")+ylim(c(0,0.5))
ggplot(clus6,aes(variable,value))+geom_boxplot()+theme_bw(20)+theme(axis.text.x = element_text(angle = 90, hjust = 1))+xlab('Activity State')+ylab("Proportion of Day")+ylim(c(0,0.5))

ggplot(merged,aes(cluster,Age))+geom_boxplot()+theme_bw(20)+theme(axis.text.x = element_text(hjust = 1))+xlab('Cluster')+ylab("Age")+ylim(c(0,100))
ggplot(merged,aes(cluster,heartAgeDataSystolicBloodPressure))+geom_boxplot()+theme_bw(20)+theme(axis.text.x = element_text(hjust = 1))+xlab('Cluster')+ylab("Diastolic Blood Pressure")+ylim(c(50,220))

sex=table(merged$Sex,merged$cluster)
sexnorm=sex 
sexnorm["Female",]=sex["Female",]/colSums(sex)
sexnorm["Male",]=sex["Male",]/colSums(sex)

ggplot(merged,aes(cluster,satisfiedwith_life))+geom_boxplot()+theme_bw(20)+xlab('Cluster')+ylab("Life Satisfaction")+ylim(c(0,10))
ggplot(merged,aes(cluster,feel_worthwhile1))+geom_boxplot()+theme_bw(20)+xlab('Cluster')+ylab("Feel worthwhile")+ylim(c(0,10))
ggplot(merged,aes(cluster,feel_worthwhile2))+geom_boxplot()+theme_bw(20)+xlab('Cluster')+ylab("Feel happy")+ylim(c(0,10))
ggplot(merged,aes(cluster,feel_worthwhile3))+geom_boxplot()+theme_bw(20)+xlab('Cluster')+ylab("Feel worried")+ylim(c(0,10))
ggplot(merged,aes(cluster,feel_worthwhile4))+geom_boxplot()+theme_bw(20)+xlab('Cluster')+ylab("Feel depressed")+ylim(c(0,10))
