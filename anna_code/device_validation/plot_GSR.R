rm(list=ls())
library(data.table)
library(ggplot2)
library(reshape2)

#GOLD STANDARD# 
gold_standard=data.frame(read.table("gold_standard.csv",header=T,sep=',',stringsAsFactors = FALSE))
gold_standard$Time=strptime(as.character(gold_standard$Time),"%Y%m%d%H%M%S")

#BASIS 
basis=data.frame(read.table("basis.csv",sep="\t",header=T,stringsAsFactors = FALSE))
basis$date=strptime(as.character(basis$date),"%Y-%m-%d %H:%M")
basis_sub=basis[20:nrow(basis),]

#APPLE# 
apple_steps=data.frame(read.table("apple_steps.csv",header=T,sep="\t",stringsAsFactors=FALSE))
apple_steps$startDate=strptime(as.character(apple_steps$startDate),"%Y%m%d%H%M%S")
apple_steps$endDate=strptime(as.character(apple_steps$endDate),"%Y%m%d%H%M%S")

#STATES
states=data.frame(read.table("states.csv",header=T,sep='\t',stringsAsFactors=FALSE))
states$Breakpoint=strptime(as.character(states$Breakpoint),"%Y%m%d%H%M%S")

#MERGE HR DATA FRAMES FOR PLOTTING 
steps_merged=merge(basis_sub,apple_steps,by.x="date",by.y="startDate",all.x=TRUE)
#steps_merged=steps_merged[15:nrow(steps_merged),]
steps_merged$Basis=steps_merged$steps
steps_merged$Apple=steps_merged$Steps
steps_merged$date=factor(as.character(steps_merged$date))

mdf<- melt(steps_merged, id="date",measure=c("Apple","Basis"))  # convert to long format
mdf$date=strptime(as.character(mdf$date),"%Y-%m-%d %H:%M")
p=ggplot(data=mdf,
         aes(x=date, y=value, colour=variable)) +  geom_point(size=5) +xlab("Time")+ylab("Steps")+ scale_fill_discrete(name="Device")
p+geom_vline(data=states, linetype=4, aes(xintercept=as.numeric(Breakpoint)) )+annotate("text", x = states$Breakpoint+120, y = rep(200,length(states$Breakpoint)), label = states$State)+theme_bw()+theme(axis.text = element_text(size = 18),
                                                                                                                                                                                                           legend.key = element_rect(fill = "navy"),
                                                                                                                                                                                                           legend.text=element_text(size=18),
                                                                                                                                                                                                           legend.background = element_rect(fill = "white"),
                                                                                                                                                                                                           legend.position = c(0.14, 0.80),
                                                                                                                                                                                                           panel.grid.major = element_blank(),
                                                                                                                                                                                                           panel.grid.minor = element_blank(),
                                                                                                                                                                                                           axis.title=element_text(size=18,face="bold"))
