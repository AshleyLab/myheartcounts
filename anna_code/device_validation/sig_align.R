rm(list=ls())
library(XML)
library(ggplot2)
library(reshape2)
library(scales)
Sys.setenv(TZ='GMT')
source('sig_align_helpers.R')
subject="6"
first=as.POSIXct(strptime(as.character("20150921071000"),"%Y%m%d%H%M%S"),tz="PDT")
last=as.POSIXct(strptime(as.character("20150921080000"),"%Y%m%d%H%M%S"),tz="PDT")


subject_dir=paste("/home/anna/scg3/subject",subject,"/",sep="")
gs_name=paste("gold_standard_details_",subject,".tsv",sep="")
states_name=paste("states_",subject,".tsv",sep="")
basis_name=paste("basis_",subject,".tsv",sep="")
fitbit_name=paste("fitbit_",subject,".tsv",sep="")
microsoft_name=paste("microsoft_",subject,".tsv",sep="")
apple_name=paste("apple_",subject,".tsv",sep="")


#READ IN GOLD STANDARD DATA 
gold_standard_det=data.frame(read.table(paste(subject_dir,gs_name,sep=""),header=T,sep='\t',stringsAsFactors = FALSE))
names(gold_standard_det)=c("gold_standard_startDate","gold_standard_hr","gold_standard_energy")
gold_standard_det$gold_standard_startDate=strptime(as.character(gold_standard_det$gold_standard_startDate),"%Y%m%d%H%M%S")
gold_standard_det$gold_standard_startDate=as.POSIXct(gold_standard_det$gold_standard_startDate,tz="PDT")
gold_standard_det$gold_standard_hr=as.numeric(gold_standard_det$gold_standard_hr)
gold_standard_det$gold_standard_energy=as.numeric(gold_standard_det$gold_standard_energy)

#READ IN THE STATE DATA 
states=data.frame(read.table(paste(subject_dir,states_name,sep=""),header=T,sep='\t',stringsAsFactors=FALSE,row.names=1))
states$startTime=strptime(as.character(states$startTime),"%Y%m%d%H%M%S")
states$endTime=strptime(as.character(states$endTime),"%Y%m%d%H%M%S")
states$startTime=as.POSIXct(states$startTime,tz="PDT")
states$endTime=as.POSIXct(states$endTime,tz="PDT")
names(states)=c("startTime","endTime","GoldStandardHRSteadyState","GoldStandardEnergySteadyState")
#READ IN BASIS DATA 
basis=data.frame(read.table(paste(subject_dir,basis_name,sep=""),sep="\t",header=T,stringsAsFactors = FALSE))
names(basis)=c("basis_startDate","basis_energy", "basis_gsr","basis_hr","basis_temp","basis_steps")
basis$basis_startDate=as.POSIXct(strptime(as.character(basis$basis_startDate),"%Y%m%d%H%M%S"),tz="PDT")
basis$basis_hr=as.numeric(basis$basis_hr)
basis$basis_energy=as.numeric(basis$basis_energy)
basis$basis_steps=as.numeric(basis$basis_steps)

#FITBIT DATA 
fitbit=data.frame(read.table(paste(subject_dir,fitbit_name,sep=""),sep='\t',header=TRUE,stringsAsFactors = FALSE))
fitbit$Date=as.POSIXct(strptime(fitbit$Date,"%Y%m%d%H%M%S"),tz="PDT")
names(fitbit)=c("fitbit_date","fitbit_hr","fitbit_energy","fitbit_steps")
fitbit$fitbit_hr=as.numeric(fitbit$fitbit_hr)
fitbit$fitbit_energy=as.numeric(fitbit$fitbit_energy)
fitbit$fitbit_steps=as.numeric(fitbit$fitbit_steps)

#MICROSOFT DATA
microsoft=data.frame(read.table(paste(subject_dir,microsoft_name,sep=""),sep="\t",header=TRUE,stringsAsFactors = FALSE))
microsoft$Time=as.POSIXct(strptime(microsoft$Time,"%Y%m%d%H%M%S"),tz="PDT")
names(microsoft)=c("microsoft_date","microsoft_hr","microsoft_energy","microsoft_steps")
microsoft$microsoft_hr=as.numeric(microsoft$microsoft_hr)
microsoft$microsoft_energy=as.numeric(microsoft$microsoft_energy)
microsoft$microsoft_steps=as.numeric(microsoft$microsoft_steps)

#READ IN APPLE DATA 
apple=data.frame(read.table(paste(subject_dir,apple_name,sep=""),sep='\t',header=TRUE, stringsAsFactors = FALSE))
apple$Date=as.POSIXct(strptime(apple$Date,"%Y-%m-%d %H:%M:%S"),tz="PDT")
apple$apple_hr=as.numeric(apple$apple_hr)
apple$apple_energy=as.numeric(apple$apple_energy)
apple$apple_steps=as.numeric(apple$apple_steps)

############################################################################################################################################
## Align the heart rate data ##
hr_basis_offset=cor.cross.sweep(basis$basis_hr,gold_standard_det$gold_standard_hr)
hr_fitbit_offset=cor.cross.sweep(fitbit$fitbit_hr,gold_standard_det$gold_standard_hr)
hr_apple_offset=cor.cross.sweep(apple$apple_hr,gold_standard_det$gold_standard_hr)
hr_microsoft_offset=cor.cross.sweep(microsoft$microsoft_hr,gold_standard_det$gold_standard_hr)

## Align the energy data ## 
energy_basis_offset=cor.cross.sweep(basis$basis_energy,gold_standard_det$gold_standard_energy)
energy_fitbit_offset=cor.cross.sweep(fitbit$fitbit_energy,gold_standard_det$gold_standard_energy)
energy_apple_offset=cor.cross.sweep(apple$apple_energy,gold_standard_det$gold_standard_energy)
energy_microsoft_offset=cor.cross.sweep(microsoft$microsoft_energy,gold_standard_det$gold_standard_energy)


## Align the step data, no gold standard, align to basis since it samples continuously## 
steps_basis_offset=cor.cross.sweep(basis$basis_steps,fitbit$fitbit_steps)
steps_apple_offset=cor.cross.sweep(apple$apple_steps,fitbit$fitbit_steps)
steps_microsoft_offset=cor.cross.sweep(microsoft$microsoft_steps,fitbit$fitbit_steps)

##############################################################################################################################################
#ADJUST SIGNAL POSITIONS BASED ON CALCULATED OFFSET FROM THE REFERENCE 
#HR
#basis
hr_length=length(gold_standard_det$gold_standard_hr)
if(hr_basis_offset < 0)
{
  prefix=rep("NA",-1*hr_basis_offset)
  hr_basis=c(prefix,basis$basis_hr)
}else
{
  hr_basis=basis$basis_hr[1+hr_basis_offset:length(basis$basis_hr)]
}
hr_basis=hr_basis[1:min(length(hr_basis),hr_length)]
if (length(hr_basis) < hr_length)
{
  pad=rep(NA,hr_length-length(hr_basis))
  hr_basis=c(hr_basis,pad)
}

#fitbit 
if(hr_fitbit_offset < 0)
{
  prefix=rep(NA,-1*hr_fitbit_offset)
  hr_fitbit=c(prefix,fitbit$fitbit_hr)
}else
{
  hr_fitbit=fitbit$fitbit_hr[1+hr_fitbit_offset:length(fitbit$fitbit_hr)]
}
hr_fitbit=hr_fitbit[1:min(length(hr_fitbit),hr_length)]
if (length(hr_fitbit) < hr_length)
{
  pad=rep(NA,hr_length-length(hr_fitbit))
  hr_fitbit=c(hr_fitbit,pad)
}

#microsoft 
if(hr_microsoft_offset < 0)
{
  prefix=rep(NA,-1*hr_microsoft_offset)
  hr_microsoft=c(prefix,microsoft$microsoft_hr)
}else
{
  hr_microsoft=microsoft$microsoft_hr[1+hr_microsoft_offset:length(microsoft$microsoft_hr)]
}
hr_microsoft=hr_microsoft[1:min(length(hr_microsoft),hr_length)]
if (length(hr_microsoft) < hr_length)
{
  pad=rep(NA,hr_length-length(hr_microsoft))
  hr_microsoft=c(hr_microsoft,pad)
}

#apple 
if(hr_apple_offset < 0)
{
  prefix=rep(NA,-1*hr_apple_offset)
  hr_apple=c(prefix,apple$apple_hr)
}else
{
  hr_apple=apple$apple_hr[1+hr_apple_offset:length(apple$apple_hr)]
}
hr_apple=hr_apple[1:min(length(hr_apple),hr_length)]
if (length(hr_apple) < hr_length)
{
  pad=rep(NA,hr_length-length(hr_apple))
  hr_apple=c(hr_apple,pad)
}

hr_df=data.frame(gold_standard_det$gold_standard_startDate,gold_standard_det$gold_standard_hr,hr_basis,hr_fitbit,hr_microsoft,hr_apple,stringsAsFactors = FALSE)
names(hr_df)=c("Date","GoldStandard","Basis","Fitbit","Microsoft","Apple")
save(hr_df,file=paste("hr_df",subject,sep="_"))
     
#ENERGY! 
#basis
energy_length=length(gold_standard_det$gold_standard_energy)
if(energy_basis_offset < 0)
{
  prefix=rep("NA",-1*energy_basis_offset)
  energy_basis=c(prefix,basis$basis_energy)
}else
{
  energy_basis=basis$basis_energy[1+energy_basis_offset:length(basis$basis_energy)]
}
energy_basis=energy_basis[1:min(length(energy_basis),energy_length)]
if (length(energy_basis) < energy_length)
{
  pad=rep(NA,energy_length-length(energy_basis))
  energy_basis=c(energy_basis,pad)
}

#fitbit 
if(energy_fitbit_offset < 0)
{
  prefix=rep(NA,-1*energy_fitbit_offset)
  energy_fitbit=c(prefix,fitbit$fitbit_energy)
}else
{
  energy_fitbit=fitbit$fitbit_energy[1+energy_fitbit_offset:length(fitbit$fitbit_energy)]
}
energy_fitbit=energy_fitbit[1:min(length(energy_fitbit),energy_length)]
if (length(energy_fitbit) < energy_length)
{
  pad=rep(NA,energy_length-length(energy_fitbit))
  energy_fitbit=c(energy_fitbit,pad)
}

#microsoft 
if(energy_microsoft_offset < 0)
{
  prefix=rep(NA,-1*energy_microsoft_offset)
  energy_microsoft=c(prefix,microsoft$microsoft_energy)
}else
{
  energy_microsoft=microsoft$microsoft_energy[1+energy_microsoft_offset:length(microsoft$microsoft_energy)]
}
energy_microsoft=energy_microsoft[1:min(length(energy_microsoft),energy_length)]
if (length(energy_microsoft) < energy_length)
{
  pad=rep(NA,energy_length-length(energy_microsoft))
  energy_microsoft=c(energy_microsoft,pad)
}

#apple 
if(energy_apple_offset < 0)
{
  prefix=rep(NA,-1*energy_apple_offset)
  energy_apple=c(prefix,apple$apple_energy)
}else
{
  energy_apple=apple$apple_energy[1+energy_apple_offset:length(apple$apple_energy)]
}
energy_apple=energy_apple[1:min(length(energy_apple),energy_length)]
if (length(energy_apple) < energy_length)
{
  pad=rep(NA,energy_length-length(energy_apple))
  energy_apple=c(energy_apple,pad)
}

energy_df=data.frame(gold_standard_det$gold_standard_startDate,as.numeric(gold_standard_det$gold_standard_energy),as.numeric(energy_basis),as.numeric(energy_fitbit),as.numeric(energy_microsoft),as.numeric(energy_apple),stringsAsFactors = FALSE)
names(energy_df)=c("Date","GoldStandard","Basis","Fitbit","Microsoft","Apple")
save(energy_df,file=paste("energy_df",subject,sep="_"))

#STEPS 
#basis
steps_length=length(fitbit$fitbit_steps)
if(steps_basis_offset < 0)
{
  prefix=rep("NA",-1*steps_basis_offset)
  steps_basis=c(prefix,basis$basis_steps)
}else
{
  steps_basis=basis$basis_steps[1+steps_basis_offset:length(basis$basis_steps)]
}
steps_basis=steps_basis[1:min(length(steps_basis),steps_length)]
if (length(steps_basis) < steps_length)
{
  pad=rep(NA,steps_length-length(steps_basis))
  steps_basis=c(steps_basis,pad)
}


#microsoft 
if(steps_microsoft_offset < 0)
{
  prefix=rep(NA,-1*steps_microsoft_offset)
  steps_microsoft=c(prefix,microsoft$microsoft_steps)
}else
{
  steps_microsoft=microsoft$microsoft_steps[1+steps_microsoft_offset:length(microsoft$microsoft_steps)]
}
steps_microsoft=steps_microsoft[1:min(length(steps_microsoft),steps_length)]
if (length(steps_microsoft) < steps_length)
{
  pad=rep(NA,steps_length-length(steps_microsoft))
  steps_microsoft=c(steps_microsoft,pad)
}

#apple 
if(steps_apple_offset < 0)
{
  prefix=rep(NA,-1*steps_apple_offset)
  steps_apple=c(prefix,apple$apple_steps)
}else
{
  steps_apple=apple$apple_steps[1+steps_apple_offset:length(apple$apple_steps)]
}
steps_apple=steps_apple[1:min(length(steps_apple),steps_length)]
if (length(steps_apple) < steps_length)
{
  pad=rep(NA,steps_length-length(steps_apple))
  steps_apple=c(steps_apple,pad)
}

steps_df=data.frame(fitbit$fitbit_date,as.numeric(fitbit$fitbit_steps),as.numeric(steps_basis),as.numeric(steps_microsoft),as.numeric(steps_apple),stringsAsFactors = FALSE)
names(steps_df)=c("Date","Fitbit","Basis","Microsoft","Apple")
#steps_df$Date=as.POSIXct(strptime(steps_df$Date,"%Y-%m-%d %H:%M:%S"),tz="PDT")
save(steps_df,file=paste("steps_df",subject,sep="_"))


###PLOT!!###
##HR
mdf<- melt(hr_df, id="Date",measure=c("GoldStandard","Basis","Fitbit","Microsoft", "Apple"))  # convert to long format
p=ggplot(data=mdf,
         aes(x=Date, y=value, col=variable)) + 
  geom_line() +
  geom_point(data=states,aes(endTime,GoldStandardHRSteadyState,col="GoldStandardHRSteadyState"),size=5)+
  theme_bw(20)+
  theme(axis.text = element_text(size = 18),
        legend.key = element_rect(fill = "navy"),
        legend.text=element_text(size=18),
        legend.background = element_rect(fill = "white"),
        legend.position = c(0.14, 0.80),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title=element_text(size=18,face="bold"))+
  annotate("text", x = states$startTime+50, y = rep(200,length(states$startTime)), label = rownames(states),size=8)+
  xlab("Time")+
  ylab("BPM")+
  scale_fill_discrete(name="Device")+
  geom_vline(data=states, linetype=4, aes(xintercept=as.numeric(endTime)) )+
  xlim(c(first,last))+ 
  scale_color_manual(values=c("#FF0000", "#66FF33", "#0000FF","#CC9900","#CC9900","#BDA0CB"))
p

#ENERGY! 
mdf<- melt(energy_df, id="Date",measure=c("GoldStandard","Basis","Fitbit","Microsoft", "Apple"))  # convert to long format
p=ggplot(data=mdf,
         aes(x=Date, y=value, col=variable)) + 
  geom_line() +
  geom_point(data=states,aes(endTime,GoldStandardEnergySteadyState,col="GoldStandardEnergySteadyState"),size=5)+
  theme_bw(20)+
  theme(axis.text = element_text(size = 18),
        legend.key = element_rect(fill = "navy"),
        legend.text=element_text(size=18),
        legend.background = element_rect(fill = "white"),
        legend.position = c(0.14, 0.80),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title=element_text(size=18,face="bold"))+
  annotate("text", x = states$startTime+50, y = rep(30,length(states$startTime)), label = rownames(states),size=8)+
  xlab("Time")+
  ylab("Kcal")+
  scale_fill_discrete(name="Device")+
  geom_vline(data=states, linetype=4, aes(xintercept=as.numeric(endTime)) )+
  xlim(c(first,last))+ 
  scale_color_manual(values=c("#FF0000", "#66FF33", "#0000FF","#CC9900","#CC9900","#BDA0CB"))
p

#STEPS! 
mdf<- melt(steps_df, id="Date",measure=c("Fitbit","Basis","Microsoft","Apple"))  # convert to long format
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
  annotate("text", x = states$startTime+50, y = rep(200,length(states$startTime)), label = rownames(states),size=8)+
  xlab("Time")+
  ylab("Steps")+
  scale_fill_discrete(name="Device")+
  geom_vline(data=states, linetype=4, aes(xintercept=as.numeric(endTime)) )+
  scale_color_manual(values=c("#FF0000", "#66FF33", "#0000FF","#BDA0CB"))+
  xlim(c(first,last))
p
