library(data.table)
library(ggplot2)
library(reshape2)
var=data.frame(read.table("HR_Variance.txt",header=F,sep='\t'))
names(var)=c("Subject","Variance")
var$Variance=sqrt(var$Variance)
meta=data.frame(read.table("NonTimeSeries.txt",header=T,sep='\t'))
merged=merge(meta,var,by="Subject")
f=glm(heartCondition~Variance,data=merged,family=binomial)
f=glm(jointProblem~Variance,data=merged,family=binomial)

p<-ggplot(merged,aes(factor(heartCondition),Variance))+geom_boxplot()+theme_bw(20)+xlab("Heart Condition")+ylab("Standard Error (bpm)")+ylim(c(0,5))
library(data.table)
library(ggplot2)
library(reshape2)
data=data.frame(read.table('deltas.csv',header=T,sep='\t'))
data$Condition=factor(data$Condition,levels=c('Hypertension (p=2.63e-12)','Vascular Disease (p=3.34e-6)','Joint Problems (p=6.88e-8)','Chest Pain (p=0.04)','Heart Disease (p=1.89e-4)'))
mdf<- melt(data, id="Condition")  # convert to long format
p=ggplot(data=mdf,
         aes(x=Condition, y=value, col=variable,group=variable)) + 
  geom_point(size=5)+
  geom_line()+
  theme_bw(20)+
  xlab("Medical Condition")+
  ylab("")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
#scale_color_manual(values=c("#FF0000", "#66FF33", "#0000FF","#CC9900","#CC9900","#BDA0CB"))

