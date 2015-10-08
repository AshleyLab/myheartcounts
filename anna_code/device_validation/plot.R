rm(list=ls())
library(data.table)
library(ggplot2)
library(reshape2)

#GOLD STANDARD# 
gold_standard=data.frame(read.table("gold_standard.csv",header=T,sep=',',stringsAsFactors = FALSE))
gold_standard$Time=strptime(as.character(gold_standard$Time),"%Y%m%d%H%M%S")

#GOLD STANDARD DETAILS
gold_standard_det=data.frame(read.table("gold_standard_details.csv",header=T,sep='\t',stringsAsFactors = FALSE))
gold_standard_det$Time=strptime(as.character(gold_standard_det$Time),"%Y%m%d%H%M%S")

#BASIS 
basis=data.frame(read.table("basis.csv",sep="\t",header=T,stringsAsFactors = FALSE))
basis$date=strptime(as.character(basis$date),"%Y-%m-%d %H:%M")
basis_sub=basis[15:nrow(basis),]

#APPLE# 
apple_hr=data.frame(read.table("apple_hr.csv",header=T,sep='\t',stringsAsFactors = FALSE))
apple_hr$startDate=strptime(as.character(apple_hr$startDate),"%Y%m%d%H%M%S")
apple_hr$endDate=strptime(as.character(apple_hr$endDate),"%Y%m%d%H%M%S")
apple_hr=apple_hr[14:79,]

#STATES
states=data.frame(read.table("states.csv",header=T,sep='\t',stringsAsFactors=FALSE))
states$Breakpoint=strptime(as.character(states$Breakpoint),"%Y%m%d%H%M%S")

#MERGE HR DATA FRAMES FOR PLOTTING 
hr_merged=merge(basis,apple_hr,by.x="date",by.y="startDate",all.x=TRUE)
hr_merged=hr_merged[15:nrow(hr_merged),]
hr_merged=merge(hr_merged,gold_standard_det,by.x="date",by.y="Time",all.x=TRUE)
hr_merged$Basis=hr_merged$heartrate
hr_merged$Apple=hr_merged$average
hr_merged$GoldStandard=hr_merged$HR
hr_merged$date=factor(as.character(hr_merged$date))

mdf<- melt(hr_merged, id="date",measure=c("Apple","Basis","GoldStandard"))  # convert to long format
mdf$date=strptime(as.character(mdf$date),"%Y-%m-%d %H:%M")

p=ggplot(data=mdf,
       aes(x=date, y=value, colour=variable)) + geom_line() +geom_point(data=gold_standard,aes(Time,HR,color="Gold Standard"),size=5)+theme_bw(20)+theme(axis.text = element_text(size = 18),
        legend.key = element_rect(fill = "navy"),
        legend.text=element_text(size=18),
        legend.background = element_rect(fill = "white"),
        legend.position = c(0.14, 0.80),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title=element_text(size=18,face="bold"))+annotate("text", x = states$Breakpoint+120, y = rep(200,length(states$Breakpoint)), label = states$State,size=8)+xlab("Time")+ylab("Heart Rate (bpm)")+ scale_fill_discrete(name="Device")+geom_vline(data=states, linetype=4, aes(xintercept=as.numeric(Breakpoint)) )
p

#ANALYZE HEART RATE DIFFERENCE
#mer