rm(list=ls())
library(ggplot2)
library(data.table)
library(reshape2)
fname="~/scg3/offsite_subject1/combined_1.tsv"
Sys.setenv(TZ='GMT')
data=data.frame(read.table(fname,header=T,sep='\t',stringsAsFactors = FALSE))
data$Date=as.POSIXct(strptime(as.character(data$Date),"%Y%m%d%H%M%S"),tz="PDT")
#READ IN THE STATE DATA 

mdf<- melt(data, id="Date",measure=c("Basis_HR","Apple_HR"))  # convert to long format
p=ggplot(data=mdf,
         aes(x=Date, y=value, col=variable)) + 
  geom_line() +
  theme_bw(20)+
  theme(axis.text = element_text(size = 18),
        legend.key = element_rect(fill = "navy"),
        legend.text=element_text(size=18),
        legend.background = element_rect(fill = "white"),
        legend.position = c(0.14, 0.80),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title=element_text(size=18,face="bold"))+
  xlab("Time")+
  ylab("BPM")+
  scale_fill_discrete(name="Device")+
  scale_color_manual(values=c("#FF0000", "#66FF33"))

p
#ENERGY! 
mdf<- melt(data, id="Date",measure=c("Basis_Energy","Apple_Energy"))  # convert to long format
p=ggplot(data=mdf,
         aes(x=Date, y=value, col=variable)) + 
  geom_line() +
  theme_bw(20)+
  theme(axis.text = element_text(size = 18),
        legend.key = element_rect(fill = "navy"),
        legend.text=element_text(size=18),
        legend.background = element_rect(fill = "white"),
        legend.position = c(0.14, 0.80),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title=element_text(size=18,face="bold"))+
  xlab("Time")+
  ylab("Kcal")+
  scale_fill_discrete(name="Device")+
  scale_color_manual(values=c("#FF0000", "#66FF33"))+
  ylim(values=c(0,15))

p

#STEPS! 
mdf<- melt(data, id="Date",measure=c("Basis_Steps","Apple_Steps"))  # convert to long format
p=ggplot(data=mdf,
         aes(x=Date, y=value, colour=variable))+ 
  geom_line()+theme_bw(20)+
  theme(axis.text = element_text(size = 18), 
        legend.key = element_rect(fill = "navy"),
        legend.text=element_text(size=18),
        legend.background = element_rect(fill = "white"),
        legend.position = c(0.14, 0.80),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title=element_text(size=18,face="bold"))+
  xlab("Time")+
  ylab("Steps")+
  scale_fill_discrete(name="Device")+
  scale_color_manual(values=c("#FF0000", "#66FF33"))+
  ylim(c(0,250))
p
