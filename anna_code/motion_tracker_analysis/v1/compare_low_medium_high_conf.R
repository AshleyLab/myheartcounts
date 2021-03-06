library(ggplot2)
library(data.table)
library(reshape2)
data_full=data.frame(read.table("~/scg2/results/feature_dataframes/Activity_states_weekday_weekend_total.tsv",header=TRUE,sep='\t'))
data_medhigh=data.frame(read.table("~/scg2/results/feature_dataframes/Activity_states_weekday_weekend_total_MEDIUM_AND_HIGH_CONFIDENCE.tsv",header=TRUE,sep='\t'))
data_high=data.frame(read.table("~/scg2/results/feature_dataframes/Activity_states_weekday_weekend_total_HIGH_CONFIDENCE.tsv",header=TRUE,sep='\t'))
blended=data.frame(data_full$Subject,data_full$CyclingTotal,data_medhigh$CyclingTotal,data_high$CyclingTotal)
names(blended)=c("Subject","All","MedHighConf","HighConf")
m=melt(blended,id.vars = "Subject")
p<- ggplot(m, aes(x = value)) + geom_density(aes(fill=factor(variable)), size=2) + theme_bw(20)+xlab("Fraction of Time Cycling")+ylab("Density")+scale_fill_discrete(guide = guide_legend(title = "Confidence"))

#Running 
blended=data.frame(data_full$Subject,data_full$RunningTotal,data_medhigh$RunningTotal,data_high$RunningTotal)
names(blended)=c("Subject","All","MedHighConf","HighConf")
m=melt(blended,id.vars = "Subject")
p<- ggplot(m, aes(x = value)) + geom_density(aes(colour=factor(variable)), size=2) + theme_bw(20)+xlab("Fraction of Time Running")+ylab("Density")+scale_color_discrete(guide = guide_legend(title = "Confidence"))+xlim(c(0,0.04))
