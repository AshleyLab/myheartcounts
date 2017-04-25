rm(list=ls())
load("hr_walk.bin")
load("hr_rest.bin")
meta=data.frame(read.table("NonTimeSeries.txt",header=T,sep='\t'))
merged=merge(meta,hr_rest,by.x="Subject",by.y="row.names")
merged$heartCondition[merged$heartCondition %in% NA]=FALSE
merged$jointProblem[merged$jointProblem %in% NA]=FALSE 
reversed=merged$delta1*-1
merged$delta1[merged$delta1 > 0]=reversed[merged$delta1 > 0]

p<-ggplot(merged,aes(factor(heartCondition),delta1))+geom_boxplot()+theme_bw(20)+xlab("Heart Condition")+ylab("6 Min Walk Recovery HR")
browser() 
p<-ggplot(merged,aes(factor(jointProblem),delta1))+geom_boxplot()+theme_bw(20)+xlab("Joint Problem")+ylab("6 Min Walk Recovery HR")
