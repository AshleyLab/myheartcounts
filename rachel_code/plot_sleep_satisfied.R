#R version 3.2.0
# sleep pattern and life satisfaction

# On SCG3
# Dir: /srv/gsfs0/projects/ashley/rachel/mhc/workspace_october2015


library("plyr")
library(ggplot2)

###########################################
# Sleep Pattern & Life Satisfaction
# Note: not in the paper
###########################################


#read in survey data

surveys = read.table("cardiovascular-satisfied-v1.tsv", sep="\t", header=T)


#summarize survey data (get means for satisfied with life for some individuals who reported multiple times)

survey_summary <- ddply(surveys, ~healthCode, summarise, feel_worthwhile1=mean(feel_worthwhile1, na.rm=T), feel_worthwhile2 = mean(feel_worthwhile2, na.rm=T), feel_worthwhile3=mean(feel_worthwhile3, na.rm=T), feel_worthwhile4=mean(feel_worthwhile4, na.rm=T), satisfiedwith_life = mean(satisfiedwith_life, na.rm=T), zip=zip[!is.na(zip)][1])


# write a csv to save this data

write.csv(survey_summary, file="healthCode.satisfied.csv",  quote=F, row.names=F)


# read in sleep pattern data

earlyRise.earlyBed = read.table("earlyRise.earlyBed.txt")
earlyRise.lateBed = read.table("earlyRise.lateBed.txt")
lateRise.lateBed = read.table("lateRise.lateBed.txt")
lateRise.earlyBed = read.table("lateRise.earlyBed.txt")


# merge sleep with satisfaction data & append labels

earlyRise.earlyBed.surveys = merge(earlyRise.earlyBed, survey_summary, by.x="V1", by.y="healthCode")
earlyRise.earlyBed.surveys$type = rep("Early Rise\nEarly Bed", nrow(earlyRise.earlyBed.surveys))

earlyRise.lateBed.surveys = merge(earlyRise.lateBed, survey_summary, by.x="V1", by.y="healthCode")
earlyRise.lateBed.surveys$type = rep("Early Rise\nLate Bed", nrow(earlyRise.lateBed.surveys))

lateRise.lateBed.surveys = merge(lateRise.lateBed, survey_summary, by.x="V1", by.y="healthCode")
lateRise.lateBed.surveys$type = rep("Late Rise\nLate Bed", nrow(lateRise.lateBed.surveys))

lateRise.earlyBed.surveys = merge(lateRise.earlyBed, survey_summary, by.x="V1", by.y="healthCode")
lateRise.earlyBed.surveys$type = rep("Late Rise\nEarly Bed", nrow(lateRise.earlyBed.surveys))


#merge to have all data in one DF

all = rbind(earlyRise.earlyBed.surveys, earlyRise.lateBed.surveys, lateRise.lateBed.surveys , lateRise.earlyBed.surveys )


# make plots! 

pdf("sleepPattern_satisfaction.pdf")
ggplot(all, aes(type, satisfiedwith_life)) + geom_boxplot() + theme_bw() + 
	theme(panel.border = element_blank(), panel.grid.major = element_blank(), 
    		panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) + ylab("Satisfaction with Life\n") + xlab("Sleep Pattern")
dev.off()

# anova + tukey
anova = aov(satisfiedwith_life~type, data=all)
summary(anova)
TukeyHSD(anova)



###########################################
# Wake time & Life Satisfaction
# Note: not in the paper
###########################################

# read in wake time data

earlyRisers = read.table("earlyRisers.sorted.txt")
lateRisers = read.table("lateRisers.sorted.txt")


# merge sleep with satisfaction data & append labels

earlyRise.surveys = merge(earlyRisers, survey_summary, by.x="V1", by.y="healthCode")
earlyRise.surveys$type = rep("Early", nrow(earlyRise.surveys))

lateRise.surveys = merge(lateRisers, survey_summary, by.x="V1", by.y="healthCode")
lateRise.surveys$type = rep("Late", nrow(lateRise.surveys))


# merge to have all data in one DF

both.wake = rbind(earlyRise.surveys, lateRise.surveys)


# make plots! 


pdf("wakeTime_satisfaction.pdf")
ggplot(both.wake, aes(type, satisfiedwith_life)) + geom_boxplot() + theme_bw() + 
	theme(panel.border = element_blank(), panel.grid.major = element_blank(), 
    		panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) + ylab("Satisfaction with Life\n") + xlab("Wake Time")
dev.off()

# t test for significance
t.wake<-t.test(earlyRise.surveys$satisfiedwith_life,lateRise.surveys$satisfiedwith_life)
t.wake$p.value





###########################################
# Bed time & Life Satisfaction
###########################################

# read in bed time data

earlyToBed = read.table("earlyToBed.sorted.txt")
lateToBed = read.table("lateToBed.sorted.txt")


# merge sleep with satisfaction data & append labels

earlyToBed.surveys = merge(earlyToBed, survey_summary, by.x="V1", by.y="healthCode")
earlyToBed.surveys$type = rep("Early", nrow(earlyToBed.surveys))

lateToBed.surveys = merge(lateToBed, survey_summary, by.x="V1", by.y="healthCode")
lateToBed.surveys$type = rep("Late", nrow(lateToBed.surveys))


# merge to have all data in one DF

both.bed = rbind(earlyToBed.surveys, lateToBed.surveys)


# make plots! 

##############################################
# Figure 3B - Bed time & Satisfaction boxplots
##############################################
pdf("bedTime_satisfaction.pdf", width=6)
ggplot(both.bed, aes(type, satisfiedwith_life)) + geom_boxplot(lwd=2, width=.5) + theme_bw(18) + 
	theme(panel.grid.major = element_blank(), 
    		panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
		panel.background = element_rect(colour = "black", fill=NA)) + ylab("Satisfaction with Life\n") + xlab("\nBed Time")
dev.off()


# beditme & satisfaction violins
pdf("bedTime_satisfaction_violin.pdf", width=6)
ggplot(both.bed, aes(type, satisfiedwith_life)) + geom_violin(lwd=2, width=.5) + theme_bw(18) + 
	theme(panel.grid.major = element_blank(), 
    		panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
		panel.background = element_rect(colour = "black", fill=NA)) + ylab("Satisfaction with Life\n") + xlab("\nBed Time")
dev.off()

# bed time and satisfaction boxplots with jitter
pdf("bedTime_satisfaction_jitter.pdf", width=6)
ggplot(both.bed, aes(type, satisfiedwith_life)) + geom_boxplot(lwd=2, width=.5, outlier.shape=NA) + geom_jitter(alpha=.2, position=position_jitter(width=0.3, height=0)) + theme_bw(18) + 
	theme(panel.grid.major = element_blank(), 
    		panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
		panel.background = element_rect(colour = "black", fill=NA)) + ylab("Satisfaction with Life\n") + xlab("\nBed Time")

dev.off()


# t- test for significance
t.bed<-t.test(earlyToBed.surveys$satisfiedwith_life,lateToBed.surveys$satisfiedwith_life)
t.bed$p.value



