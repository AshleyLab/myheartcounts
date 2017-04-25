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
apple_calories=data.frame(read.table("apple_calories.csv",header=T,sep="\t",stringsAsFactors=FALSE))
apple_calories$startDate=strptime(as.character(apple_calories$startDate),"%Y%m%d%H%M%S")
apple_calories$endDate=strptime(as.character(apple_calories$endDate),"%Y%m%d%H%M%S")
apple_calories=apple_calories[137:nrow(apple_calories),]

#STATES
states=data.frame(read.table("states.csv",header=T,sep='\t',stringsAsFactors=FALSE))
states$Breakpoint=strptime(as.character(states$Breakpoint),"%Y%m%d%H%M%S")

#MERGE HR DATA FRAMES FOR PLOTTING 
cal_merged=merge(basis,apple_calories,by.x="date",by.y="startDate",all.x=TRUE)
cal_merged=cal_merged[15:nrow(cal_merged),]
cal_merged=merge(cal_merged,gold_standard_det,by.x="date",by.y="Time",all.x=TRUE)
cal_merged$Basis=cal_merged$calories
cal_merged$Apple=cal_merged$kcal
cal_merged$GoldStandard=cal_merged$Energy
cal_merged$date=factor(as.character(cal_merged$date))

mdf<- melt(cal_merged, id="date",measure=c("Apple","Basis","GoldStandard"))  # convert to long format
mdf$date=strptime(as.character(mdf$date),"%Y-%m-%d %H:%M")
p=ggplot(data=mdf,
         aes(x=date, y=value, colour=variable)) + geom_line() +geom_point(data=gold_standard,aes(Time,ENERGY,color="Gold Standard"),size=5)+theme_bw()+theme(axis.text = element_text(size = 18),
                                                                                                                                                         legend.key = element_rect(fill = "navy"),
                                                                                                                                                         legend.text=element_text(size=18),
                                                                                                                                                         legend.background = element_rect(fill = "white"),
                                                                                                                                                         legend.position = c(0.14, 0.80),
                                                                                                                                                         panel.grid.major = element_blank(),
                                                                                                                                                         panel.grid.minor = element_blank(),
                                                                                                                                                         axis.title=element_text(size=18,face="bold"))+annotate("text", x = states$Breakpoint+120, y = rep(20,length(states$Breakpoint)), label = states$State,size=8)+xlab("Time")+ylab("Kcal")+ scale_fill_discrete(name="Device")+geom_vline(data=states, linetype=4, aes(xintercept=as.numeric(Breakpoint)) )
p


