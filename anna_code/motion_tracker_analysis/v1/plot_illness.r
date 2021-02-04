rm(list=ls()) 
library(data.table)
data<-as.data.frame(read.table('illness.csv',header=TRUE,row.names=1,as.is=TRUE,sep=","))
as.data.frame(read.table('illness.csv',header=TRUE,row.names=1,as.is=TRUE,sep=","))
png('illness.png',width=8.25,height=6.25,units="in",res=600) 
par(mfrow=c(2,3))
barplot(data$HeartCondition,names=rownames(data),xlab="Cluster",ylab="Fraction with Heart Condition")
barplot(data$HeartDisease,names=rownames(data),xlab="Cluster",ylab="Fraction with Heart Disease")
barplot(data$ChestPain,names=rownames(data),xlab="Cluster",ylab="Fraction with Chest Pain")
barplot(data$JointPain,names=rownames(data),xlab="Cluster",ylab="Fraction with Joint Pain")
barplot(data$Dizziness,names=rownames(data),xlab="Cluster",ylab="Fraction with Dizziness")
dev.off()


