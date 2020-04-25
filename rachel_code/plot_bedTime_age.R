#R version 3.2.0
# sleep pattern and age

# On SCG3
# Dir: /srv/gsfs0/projects/ashley/rachel/mhc/workspace_october2015

library(ggplot2)

# read in age + healthcode data

load("Table2.RData")
#DF named data

### Data cleaning ###
data$Meters[data$Meters>2000] <- NA
data$Age[data$Age>100] <- NA
data$Vig_and_Moder[data$Vig_and_Moder>2000] <- NA
data$sleep_time[data$sleep_time>20] <- NA
data$Active[data$Active>.8] <- NA


# read in bed time data

earlyToBed = read.table("earlyToBed.sorted.txt")
lateToBed = read.table("lateToBed.sorted.txt")


# merge bed time data with age and label

earlyBed.age = merge(earlyToBed, data, by.x="V1", by.y="Subject")
earlyBed.age$bedTime = rep("Early", nrow(earlyBed.age))

lateBed.age = merge(lateToBed, data, by.x="V1", by.y="Subject")
lateBed.age$bedTime = rep("Late", nrow(lateBed.age))


# combine into one big DF for plotting

bed.age = rbind(earlyBed.age, lateBed.age)


# make plots!


##################################################
## Supplemental Figure 2 - Bed Time & Age
##################################################

pdf("bedTime.age.pdf")
ggplot(bed.age, aes(Age, fill=bedTime)) +geom_density(alpha=.5) + theme_bw(20) + guides(fill=guide_legend(title="Bed Time")) + xlab("\nAge") + ylab("Density\n") +  scale_fill_manual(values=c("#dfc27d","#018571")) + 	
	theme(panel.grid.major = element_blank(), 
    		panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"),
		panel.background = element_rect(colour = "black", fill=NA)) + 
	theme(legend.position=c(.8,.8)) 
dev.off()



## Looking at Sleep Pattern and Age - Note not in paper.


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


# merge with age info
all.age= merge(all, data, by.x="V1", by.y="Subject")

# Sleep pattern relationship with age - not in paper.
pdf("sleepPattern.age.pdf")
ggplot(all.age, aes(Age, fill=type)) +geom_density(alpha=.5) + theme_bw(26) 
dev.off()

