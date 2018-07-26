rm(list=ls())
library(data.table)
library(ggplot2)
library(reshape2)
data=data.frame(read.table("HeartAgeRelatedPredictions.txt",sep="\t",header=TRUE,row.names = 1))

#TRUE AGE VS PREDICTED HEART AGE ! 
agecor=round(cor(data$Age,data$HeartAge),2)
maintitle=paste("True Age vs Heart Age: R^2=",agecor,sep=" ")
p<-ggplot(data, aes(Age, HeartAge),ylab="Predicted Heart Age") + geom_point(aes(fill="blue"),alpha = 1/5,pch=22,color="black")+ xlab("True Subject Age") +
  ylab("Predicted Heart Age") +
  ggtitle(maintitle)+
  ylim(20,100)+
  xlim(20,100)+
  geom_abline(slope=1, intercept=0)+
  geom_abline(slope=0.96,intercept=6.07)+
  theme(axis.text.x=element_text(colour="black"))+
  theme(axis.text.y=element_text(colour="black"))+
  theme_bw(20)
p
bmi_bad=c(39.3765138408,
          29.1242857143,
          31.5171592938,
          28.7280301527,
          29.6984953704)  

bmi_good=c(21.6307692308,
           33.4283673469,
           21.09,
           22.8475)
boxplot(bmi_bad,bmi_good,names=c("Heart Age >> Age", "Heart Age << Age"),ylab="BMI")
#GET GROUP FOR 10 YEAR RISK (40-79 year old)
g10year_index=which(data$Age>39)
g10year=data[g10year_index,]
g10year$RiskFactors1<-factor(g10year$RiskFactors1)
g10year$RiskFactors2<-factor(g10year$RiskFactors2)

ggplot(g10year, aes(X10YearRisk, fill = RiskFactors1)) + geom_density(alpha = 0.2)+  theme(axis.text.x=element_text(colour="black"))+
  theme(axis.text.y=element_text(colour="black"))+ylab('Denstiry')+xlab('Calculated 10 Year Risk')+labs(colour="Self-Perceived Risk")
g1<-g10year[ which(g10year$Age>39 & g10year$Age <51),]
g2<-g10year[ which(g10year$Age>50 & g10year$Age <61),]
g3<-g10year[ which(g10year$Age>60 & g10year$Age <71),]
g4<-g10year[ which(g10year$Age>70 & g10year$Age <81),]

ggplot(g1, aes(X10YearRisk, fill = RiskFactors2)) + geom_density(alpha = 0.2)+  theme(axis.text.x=element_text(colour="black"))+
  theme(axis.text.y=element_text(colour="black"))+ylab('Denstiry')+xlab('Calculated 10 Year Risk')+labs(colour="Self-Perceived Risk")


#GET GROUP FOR LIFETIME RISK (20-59 year old)
glife1_index=which(data$Age>20)
glife2_index=which(data$Age<60) 
glife_index=intersect(glife1_index,glife2_index)
glife=data[glife_index,]
glife$RiskFactors3<-factor(glife$RiskFactors3)
glife$RiskFactors4<-factor(glife$RiskFactors4)

ggplot(glife, aes(LifetimeRisk95, fill = RiskFactors3)) + geom_density(alpha = 0.2)+  theme(axis.text.x=element_text(colour="black"))+
  theme(axis.text.y=element_text(colour="black"))+ylab('Densitry')+xlab('Calculated Lifetime Risk')+labs(colour="Self-Perceived Risk")

#PLOT AGE VS 10 YEAR & LIFETIME RISK, FOR PLOT ON CALCULATED VS PERCEIVED RISK 
meta=data.frame(read.table("NonTimeSeries.txt",header=T,sep='\t'))
merged=merge(meta,data,by.x="Subject",by.y="row.names")
moi=subset(merged,select=c("X10YearRisk","LifetimeRisk75","RiskFactors1","RiskFactors2","RiskFactors3","RiskFactors4","Age.y"))
p <- ggplot(moi, aes(factor(RiskFactors1), X10YearRisk))+
     geom_boxplot()+
     theme_bw(20)+
     xlab("Self-Predicted 10-Year Risk : 1(Not at all) to 5 (Extremely)")+
     ylab("Calculated 10-Year Risk")+
     ylim(c(0,40))+
     annotate("text", x = 4, y =35, label = "Pearson cor.=0.18",size=10)

p <- ggplot(moi, aes(factor(RiskFactors2), X10YearRisk))+
  geom_boxplot()+
  theme_bw(20)+
  xlab("Self-Predicted 10-Year Risk Relative to Others: 1(Lower) to 5 (Higher)")+
  ylab("Calculated 10-Year Risk")+
  ylim(c(0,40))+
  annotate("text", x = 4, y =35, label = "Pearson cor.=0.09",size=10)

p <- ggplot(moi, aes(factor(RiskFactors3), LifetimeRisk75))+
  geom_boxplot()+
  theme_bw(20)+
  xlab("Self-Predicted Lifetime Risk: 1(Not at all) to 5 (Extremely)")+
  ylab("Calculated Lifetime Risk")+
  ylim(c(0,40))+
  annotate("text", x = 4, y =35, label = "Pearson cor.=0.09",size=10)

p <- ggplot(moi, aes(factor(RiskFactors4), X10YearRisk))+
  geom_boxplot()+
  theme_bw(20)+
  xlab("Self-Predicted Lifetime Risk Relative to Others: 1(Much Lower) to 5 (Much Higher)")+
  ylab("Calculated Lifetime Risk")+
  ylim(c(0,40))+
  annotate("text", x = 4, y =35, label = "Pearson cor.=0.15",size=10)
