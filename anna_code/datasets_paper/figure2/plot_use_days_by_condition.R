rm(list=ls())
library(ggplot2)
source('~/helpers.R')
data=read.table("use_days_by_condition.txt",header=TRUE,row.names=1,sep='\t')
# Outlier removal by the Tukey rules on quartiles +/- 1.5 IQR
# 2017 Klodian Dhana


outlierKD <- function(dt, var) {
  var_name <- eval(substitute(var),eval(dt))
  tot <- sum(!is.na(var_name))
  na1 <- sum(is.na(var_name))
  m1 <- mean(var_name, na.rm = T)
  par(mfrow=c(2, 2), oma=c(0,0,3,0))
  boxplot(var_name, main="With outliers")
  hist(var_name, main="With outliers", xlab=NA, ylab=NA)
  outlier <- boxplot.stats(var_name)$out
  mo <- mean(outlier)
  var_name <- ifelse(var_name %in% outlier, NA, var_name)
  boxplot(var_name, main="Without outliers")
  hist(var_name, main="Without outliers", xlab=NA, ylab=NA)
  title("Outlier Check", outer=TRUE)
  na2 <- sum(is.na(var_name))
  message("Outliers identified: ", na2 - na1, " from ", tot, " observations")
  message("Proportion (%) of outliers: ", (na2 - na1) / tot*100)
  message("Mean of the outliers: ", mo)
  m2 <- mean(var_name, na.rm = T)
  message("Mean without removing outliers: ", m1)
  message("Mean if we remove outliers: ", m2)
  response <- readline(prompt="Do you want to remove outliers and to replace with NA? [yes/no]: ")
  if(response == "y" | response == "yes"){
    dt[as.character(substitute(var))] <- invisible(var_name)
    assign(as.character(as.list(match.call())$dt), dt, envir = .GlobalEnv)
    message("Outliers successfully removed", "\n")
    return(invisible(dt))
  } else{
    message("Nothing changed", "\n")
    return(invisible(var_name))
  }
}
data=outlierKD(data,DaysWithData)
fam_hist=subset(data,select=c("DaysWithData","FamilyHistory"))
fam_hist=na.omit(fam_hist)
p1=ggplot(data=fam_hist,
          aes(y=fam_hist$DaysWithData,x=factor(fam_hist$FamilyHistory)))+
  geom_boxplot()+
  xlab("Family History of Cardiovascular Disease")+
  ylab("Duration of App Usage")+
  theme_bw(15)+
  ggtitle("p adj=1.73e-4, diff=0.23+/-0.13")

aov1<-aov(DaysWithData~FamilyHistory,data=fam_hist)
tk1<-TukeyHSD(aov1,conf.level=0.95)

##########################################################################################

heart_disease=subset(data,select=c("DaysWithData","HeartDisease"))
heart_disease=na.omit(heart_disease)
aov2<-aov(DaysWithData~HeartDisease,data=heart_disease)
tk2<-TukeyHSD(aov2,conf.level=0.95)


p2=ggplot(data=heart_disease,
          aes(y=heart_disease$DaysWithData,x=factor(heart_disease$HeartDisease)))+
  geom_boxplot()+
  xlab("Heart Disease")+
  ylab("Duration of App Usage")+
  theme_bw(15)+
  ggtitle("p adj=8.78e-10, diff=0.56+/-0.18")
#############################################################
vascular_disease=subset(data,select=c("DaysWithData","VascularDisease"))
vascular_disease=na.omit(vascular_disease)
aov3<-aov(DaysWithData~VascularDisease,data=vascular_disease)
tk3<-TukeyHSD(aov3,conf.level=0.95)


p3=ggplot(data=vascular_disease,
          aes(y=vascular_disease$DaysWithData,x=factor(vascular_disease$VascularDisease)))+
  geom_boxplot()+
  xlab("VascularDisease")+
  ylab("Duration of App Usage")+
  theme_bw(15)+
  ggtitle("p adj=1.90e-4, diff=0.47+/-0.25")
#############################################################
multiplot(p1,p2,p3,cols=3)
#############################################################
worthwhile=subset(data,select=c("DaysWithData","Worthwhile"))
worthwhile=na.omit(worthwhile)
lmfit4<-lm(DaysWithData~Worthwhile,data=worthwhile)
worthwhile$Binned="Medium"
worthwhile$Binned[worthwhile$Worthwhile<4]="Low"
worthwhile$Binned[worthwhile$Worthwhile>6]="High"
worthwhile$Binned=factor(worthwhile$Binned,levels=c("Low","Medium","High"))
p4=ggplot(data=worthwhile,
          aes(y=worthwhile$DaysWithData,x=worthwhile$Binned))+
  geom_boxplot()+
  xlab("Feel Worthwhile")+
  ylab("Duration of App Usage")+
  theme_bw(10)+
  ggtitle("p<2.2e-16, beta=0.13+/-0.013")
#############################################################
happy=subset(data,select=c("DaysWithData","Happy"))
happy=na.omit(happy) 
lmfit5=lm(DaysWithData~Happy,data=happy)
happy$Binned="Medium"
happy$Binned[happy$Happy<4]="Low"
happy$Binned[happy$Happy>6]="High"
happy$Binned=factor(happy$Binned,levels=c("Low","Medium","High"))
p5=ggplot(data=happy,
          aes(y=happy$DaysWithData,x=happy$Binned))+
  geom_boxplot()+
  xlab("Feel happy")+
  ylab("Duration of App Usage")+
  theme_bw(10)+
  ggtitle("p<2.2e-16, beta=0.12+/-0.12")+
  xlab("Happy")

#############################################################
worried=subset(data,select=c("DaysWithData","Worried"))
worried=na.omit(worried) 
lmfit6=lm(DaysWithData~Worried,data=worried)
worried$Binned="Medium"
worried$Binned[worried$Worried<4]="Low"
worried$Binned[worried$Worried>6]="High"
worried$Binned=factor(worried$Binned,levels=c("Low","Medium","High"))
p6=ggplot(data=worried,
          aes(y=worried$DaysWithData,x=worried$Binned))+
  geom_boxplot()+
  xlab("Feel worried")+
  ylab("Duration of App Usage")+
  theme_bw(10)+
  ggtitle("p<2.2e-16, beta=-0.13+/-0.01")+
  xlab("Worried")
#############################################################
depressed=subset(data,select=c("DaysWithData","Depressed"))
depressed=na.omit(depressed) 
lmfit7=lm(DaysWithData~Depressed,data=depressed)
depressed$Binned="Medium"
depressed$Binned[depressed$Depressed<4]="Low"
depressed$Binned[depressed$Depressed>6]="High"
depressed$Binned=factor(depressed$Binned,levels=c("Low","Medium","High"))
p7=ggplot(data=depressed,
          aes(y=depressed$DaysWithData,x=depressed$Binned))+
  geom_boxplot()+
  xlab("Feel depressed")+
  ylab("Duration of App Usage")+
  theme_bw(10)+
  ggtitle("p<2.2e-16, beta=-0.094+/-0.01")+
  xlab("Depressed")
#############################################################
multiplot(p4,p5,p6,p7,cols=4)
#############################################################
risk1=subset(data,select=c("DaysWithData","Risk1"))
risk1=na.omit(risk1) 
lmfit8=lm(DaysWithData~Risk1,data=risk1)
risk1$Binned="Medium"
risk1$Binned[risk1$Risk1<3]="Low"
risk1$Binned[risk1$Risk1>3]="High"
risk1$Binned=factor(risk1$Binned,levels=c("Low","Medium","High"))
p8=ggplot(data=risk1,
          aes(y=risk1$DaysWithData,x=factor(risk1$Binned)))+
  geom_boxplot()+
  xlab("Perceived 10-Year Risk")+
  ylab("Duration of App Usage")+
  theme_bw(10)+
  ggtitle("p<2.2e-16, beta=0.29+/-0.03")

#############################################################
risk2=subset(data,select=c("DaysWithData","Risk2"))
risk2=na.omit(risk2) 
lmfit9=lm(DaysWithData~Risk2,data=risk2)
risk2$Binned="Medium"
risk2$Binned[risk2$Risk2<3]="Low"
risk2$Binned[risk2$Risk2>3]="High"
risk2$Binned=factor(risk2$Binned,levels=c("Low","Medium","High"))
p9=ggplot(data=risk2,
          aes(y=risk2$DaysWithData,x=factor(risk2$Binned)))+
  geom_boxplot()+
  xlab("Perceived 10-Year Risk Compared to Others")+
  ylab("Duration of App Usage")+
  theme_bw(10)+
  ggtitle("p=7.93e-4, beta=0.079+/-0.02")

#############################################################
risk3=subset(data,select=c("DaysWithData","Risk3"))
risk3=na.omit(risk3) 
lmfit10=lm(DaysWithData~Risk3,data=risk3)
risk3$Binned="Medium"
risk3$Binned[risk3$Risk3<3]="Low"
risk3$Binned[risk3$Risk3>3]="High"
risk3$Binned=factor(risk3$Binned,levels=c("Low","Medium","High"))
p10=ggplot(data=risk3,
          aes(y=risk3$DaysWithData,x=factor(risk3$Binned)))+
  geom_boxplot()+
  xlab("Perceived Lifetime Risk")+
  ylab("Duration of App Usage")+
  theme_bw(10)+
  ggtitle("p=3.18e-5, beta=0.105+/-0.02")


#############################################################
risk4=subset(data,select=c("DaysWithData","Risk4"))
risk4=na.omit(risk4) 
lmfit11=lm(DaysWithData~Risk4,data=risk4)
risk4$Binned="Medium"
risk4$Binned[risk4$Risk4<3]="Low"
risk4$Binned[risk4$Risk4>3]="High"
risk4$Binned=factor(risk4$Binned,levels=c("Low","Medium","High"))
p11=ggplot(data=risk4,
          aes(y=risk4$DaysWithData,x=factor(risk4$Binned)))+
  geom_boxplot()+
  xlab("Perceived Lifetime Risk Compared to Others")+
  ylab("Duration of App Usage")+
  theme_bw(10)+
  ggtitle("p=2.81e-3, beta=0.079+/-0.02")

#############################################################
multiplot(p8,p9,p10,p11,cols=4)
#########################################################################

fam_hist$Metric="Family History"
heart_disease$Metric="Heart Disease"
vascular_disease$Metric="Vascular Disease"
names(fam_hist)=c("DaysWithData","Choice","Metric")
names(heart_disease)=c("DaysWithData","Choice","Metric")
names(vascular_disease)=c("DaysWithData","Choice","Metric")

merged=rbind(fam_hist,heart_disease,vascular_disease)
merged$Metric=factor(merged$Metric)
merged$Choice=factor(merged$Choice)
p20=ggplot(data=merged,
       aes(y=merged$DaysWithData,x=factor(merged$Metric)))+
  geom_boxplot(size=2,aes(color=Choice))+
  xlab("Health Metric")+
  ylab("Duration of App Usage")+
  theme_bw(20)+
  ggtitle("Self-Reported Health Metrics vs App Usage")+
  scale_color_manual(values=c('#1b9e77','#d95f02','#7570b3'))


worthwhile$Metric="Worthwhile"
happy$Metric="Happy"
worried$Metric="Worried"
depressed$Metric="Depressed"
names(worthwhile)=c("DaysWithData","Value","Binned","Metric")
names(happy)=c("DaysWithData","Value","Binned","Metric")
names(worried)=c("DaysWithData","Value","Binned","Metric")
names(depressed)=c("DaysWithData","Value","Binned","Metric")
merged2=rbind(worthwhile,happy,worried,depressed)
merged2$Binned=factor(merged2$Binned)
merged2$Metric=factor(merged2$Metric,levels=c("Happy","Worthwhile","Worried","Depressed"))
p21=ggplot(data=merged2,
           aes(y=merged2$DaysWithData,x=merged2$Metric))+
  geom_boxplot(size=2,aes(color=Binned))+
  xlab("Mental Well-Being Metric")+
  ylab("Duration of App Usage")+
  theme_bw(20)+
  ggtitle("Self-Reported Mental Wellbeing vs App Usage")+
  scale_color_manual(values=c('#d95f02','#7570b3','#1b9e77'))


risk1$Metric="10-Year Risk"
risk2$Metric="10-Year Risk vs Others"
risk3$Metric="Lifetime Risk"
risk4$Metric="Lifetime Risk vs Others"
names(risk1)=c("DaysWithData","Value","Binned","Metric")
names(risk2)=c("DaysWithData","Value","Binned","Metric")
names(risk3)=c("DaysWithData","Value","Binned","Metric")
names(risk4)=c("DaysWithData","Value","Binned","Metric")
merged3=rbind(risk1,risk2,risk3,risk4)
merged3$Binned=factor(merged3$Binned)
merged3$Metric=factor(merged3$Metric,levels=c("10-Year Risk","Lifetime Risk","10-Year Risk vs Others","Lifetime Risk vs Others"))
p22=ggplot(data=merged3,
           aes(y=merged3$DaysWithData,x=merged3$Metric))+
  geom_boxplot(size=2,aes(color=Binned))+
  xlab("Risk Perception Metric")+
  ylab("Duration of App Usage")+
  theme_bw(20)+
  ggtitle("Perception of Cardiovascular Risk")+
  scale_color_manual(values=c('#d95f02','#7570b3','#1b9e77'))

multiplot(p20,p21,p22,ncol=1)
