rm(list=ls())
library(ggplot2)
library(data.table)
library(reshape2)
fname="~/scg3/subject58/combined_58.tsv"
state_name="~/scg3/subject58/DVSTUDY58.csv.STATES"
Sys.setenv(TZ='GMT')
#first=as.POSIXct(strptime(as.character("20158828070000"),"%Y%m%d%H%M%S"),tz="PDT")
#last=as.POSIXct(strptime(as.character ("20158828083000"),"%Y%m%d%H%M%S"),tz="PDT")
data=data.frame(read.table(fname,header=T,sep='\t',stringsAsFactors = FALSE))
data$Date=as.POSIXct(strptime(as.character(data$Date),"%Y%m%d%H%M%S"),tz="PDT")
#READ IN THE STATE DATA 
states=data.frame(read.table(state_name,header=T,stringsAsFactors=FALSE,row.names=1))
states$startTime=strptime(as.character(states$startTime),"%Y%m%d%H%M%S")
states$endTime=strptime(as.character(states$endTime),"%Y%m%d%H%M%S")
states$startTime=as.POSIXct(states$startTime,tz="PDT")
states$endTime=as.POSIXct(states$endTime,tz="PDT")
names(states)=c("startTime","endTime","GoldStandardHRSteadyState","GoldStandardEnergySteadyState")

mdf<- melt(data, id="Date",measure=c("GoldStandard_HR","Mio_HR","Samsung_HR","Pulseon_HR"))  # convert to long format
mio_mdf=subset(mdf,variable=="Mio_HR"); 
p=ggplot(data=mdf,
         aes(x=Date, y=value, col=variable)) + 
  geom_line() +
  geom_point(data=states,aes(endTime,GoldStandardHRSteadyState,col="GoldStandardHRSteadyState"),size=5)+
  geom_point(data=mio_mdf,aes(Date,value,col="Mio_HR"),size=2)+
  theme_bw(20)+
  theme(axis.text = element_text(size = 18),
        legend.key = element_rect(fill = "navy"),
        legend.text=element_text(size=18),
        legend.background = element_rect(fill = "white"),
        legend.position = c(0.10, 0.70),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title=element_text(size=18,face="bold"))+
  annotate("text", x = states$startTime+58, y = rep(200,length(states$startTime)), label = rownames(states),size=8)+
  xlab("Time")+
  ylab("BPM")+
  scale_fill_discrete(name="Device")+
  geom_vline(data=states, linetype=4, aes(xintercept=as.numeric(endTime)) )+
  scale_color_manual(values=c("#CC9900","#CC9900","#FF0000", "#66FF33", "#0000FF"))#,"#BDA0CB"))
  #xlim(c(first,last))+ 
p
#browser() 
#ENERGY! 
# mdf<- melt(data, id="Date",measure=c("GoldStandard_Energy","Basis_Energy","Fitbit_Energy","Microsoft_Energy", "Apple_Energy"))  # convert to long format
# p=ggplot(data=mdf,
#          aes(x=Date, y=value, col=variable)) + 
#   geom_line() +
#   geom_point(data=states,aes(endTime,GoldStandardEnergySteadyState,col="GoldStandardEnergySteadyState"),size=5)+
#   theme_bw(20)+
#   theme(axis.text = element_text(size = 18),
#         legend.key = element_rect(fill = "navy"),
#         legend.text=element_text(size=18),
#         legend.background = element_rect(fill = "white"),
#         legend.position = c(0.14, 0.70),
#         panel.grid.major = element_blank(),
#         panel.grid.minor = element_blank(),
#         axis.title=element_text(size=18,face="bold"))+
#   annotate("text", x = states$startTime+58, y = rep(30,length(states$startTime)), label = rownames(states),size=8)+
#   xlab("Time")+
#   ylab("Kcal")+
#   scale_fill_discrete(name="Device")+
#   geom_vline(data=states, linetype=4, aes(xintercept=as.numeric(endTime)) )+
#   scale_color_manual(values=c("#FF0000", "#66FF33", "#0000FF","#CC9900","#CC9900","#BDA0CB"))
#   #xlim(c(first,last))+ 
#   
# p
# browser() 
# #STEPS! 
# mdf<- melt(data, id="Date",measure=c("Fitbit_Steps","Basis_Steps","Microsoft_Steps","Apple_Steps"))  # convert to long format
# p=ggplot(data=mdf,
#          aes(x=Date, y=value, colour=variable))+ 
#   geom_line()+theme_bw(20)+
#   theme(axis.text = element_text(size = 18), 
#         legend.key = element_rect(fill = "navy"),
#         legend.text=element_text(size=18),
#         legend.background = element_rect(fill = "white"),
#         legend.position = c(0.14, 0.70),
#         panel.grid.major = element_blank(),
#         panel.grid.minor = element_blank(),
#         axis.title=element_text(size=18,face="bold"))+
#   annotate("text", x = states$startTime+58, y = rep(200,length(states$startTime)), label = rownames(states),size=8)+
#   xlab("Time")+
#   ylab("Steps")+
#   scale_fill_discrete(name="Device")+
#   geom_vline(data=states, linetype=4, aes(xintercept=as.numeric(endTime)) )+
#   scale_color_manual(values=c("#FF0000", "#66FF33", "#0000FF","#BDA0CB"))
#   #xlim(c(first,last))
# p
