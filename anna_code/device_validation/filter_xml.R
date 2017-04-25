rm(list=ls())
library(XML)
library(ggplot2)
library(reshape2)
library(scales)
Sys.setenv(TZ='GMT')

#THESE GET MODIFIED: 
subjectnum="32"
subject_dir=paste("/home/anna/scg3/subject",subjectnum,"/",sep="")
fname=paste("export_",subjectnum,".xml",sep="")
first=as.POSIXct(strptime(as.character("20151007070000"),"%Y%m%d%H%M%S"),tz="PDT")
last=as.POSIXct(strptime(as.character( "20151007083000"),"%Y%m%d%H%M%S"),tz="PDT")


#READ IN APPLE DATA
apple_hr=c() 
apple_hr_startDate=c() 
apple_hr_endDate=c() 

apple_energy=c() 
apple_energy_startDate=c() 
apple_energy_endDate=c() 

apple_steps=c() 
apple_steps_startDate=c() 
apple_steps_endDate=c() 

#build apple data frame 
apple_xml=xmlToList(xmlParse(paste(subject_dir,fname,sep="")))
for(i in 1:length(apple_xml))
{
  if(is.na(apple_xml[[i]]["type"]))
    next 
  fromwatch=grepl("Watch",apple_xml[[i]][["source"]])
  if(fromwatch==FALSE)
    next
  cur_type=apple_xml[[i]][["type"]]
  if(cur_type=="HKQuantityTypeIdentifierHeartRate")
  {
    if(is.na(apple_xml[[i]]["average"]))
      apple_hr=c(apple_hr,60*as.numeric(apple_xml[[i]][["value"]]))
    else{
      apple_hr=c(apple_hr,60*as.numeric(apple_xml[[i]][["average"]]))
    }
    apple_hr_startDate=c(apple_hr_startDate,apple_xml[[i]][["startDate"]])
    apple_hr_endDate=c(apple_hr_endDate,apple_xml[[i]][["endDate"]])
  }
  else if(cur_type=="HKQuantityTypeIdentifierActiveEnergyBurned")
  {
    apple_energy=c(apple_energy,as.numeric(apple_xml[[i]][["value"]]))
    apple_energy_startDate=c(apple_energy_startDate,apple_xml[[i]]["startDate"])
    apple_energy_endDate=c(apple_energy_endDate,apple_xml[[i]]["endDate"])
  }
  else if (cur_type=="HKQuantityTypeIdentifierStepCount")
  {
    apple_steps=c(apple_steps,as.numeric(apple_xml[[i]][["value"]]))
    apple_steps_startDate=c(apple_steps_startDate,apple_xml[[i]]["startDate"])
    apple_steps_endDate=c(apple_steps_endDate,apple_xml[[i]]["endDate"])
    
  }
}
#convert Apple data to dataframe 
apple_hr_df=data.frame(apple_hr,apple_hr_startDate,apple_hr_endDate)
apple_hr_df$apple_hr_startDate=strptime(as.character(apple_hr_df$apple_hr_startDate),"%Y%m%d%H%M")
apple_hr_df$apple_hr_endDate=strptime(as.character(apple_hr_df$apple_hr_endDate),"%Y%m%d%H%M")
apple_hr_df$apple_hr_startDate=as.POSIXct(apple_hr_df$apple_hr_startDate,tz="PDT")
apple_hr_df$apple_hr_endDate=as.POSIXct(apple_hr_df$apple_hr_endDate,tz="PDT")
apple_hr_df=apple_hr_df[(apple_hr_df$apple_hr_startDate >=first) & (apple_hr_df$apple_hr_endDate<=last),]
apple_hr_df=aggregate(apple_hr~apple_hr_startDate+apple_hr_endDate,data=apple_hr_df, FUN=mean) 


apple_energy_df=data.frame(apple_energy,apple_energy_startDate,apple_energy_endDate)
apple_energy_df$apple_energy_startDate=strptime(as.character(apple_energy_df$apple_energy_startDate),"%Y%m%d%H%M")
apple_energy_df$apple_energy_endDate=strptime(as.character(apple_energy_df$apple_energy_endDate),"%Y%m%d%H%M")
apple_energy_df$apple_energy_startDate=as.POSIXct(apple_energy_df$apple_energy_startDate,tz="PDT")
apple_energy_df$apple_energy_endDate=as.POSIXct(apple_energy_df$apple_energy_endDate,tz="PDT")
apple_energy_df=apple_energy_df[(apple_energy_df$apple_energy_startDate >=first) & (apple_energy_df$apple_energy_endDate<=last),]
apple_energy_df=aggregate(apple_energy~apple_energy_startDate+apple_energy_endDate,data=apple_energy_df, FUN=mean) 

apple_steps_df=data.frame(apple_steps,apple_steps_startDate,apple_steps_endDate)
apple_steps_df$apple_steps_startDate=strptime(as.character(apple_steps_df$apple_steps_startDate),"%Y%m%d%H%M")
apple_steps_df$apple_steps_endDate=strptime(as.character(apple_steps_df$apple_steps_endDate),"%Y%m%d%H%M")
apple_steps_df$apple_steps_startDate=as.POSIXct(apple_steps_df$apple_steps_startDate,tz="PDT")
apple_steps_df$apple_steps_endDate=as.POSIXct(apple_steps_df$apple_steps_endDate,tz="PDT")
apple_steps_df=apple_steps_df[(apple_steps_df$apple_steps_startDate >=first) & (apple_steps_df$apple_steps_endDate<=last),]
apple_steps_df=aggregate(apple_steps~apple_steps_startDate+apple_steps_endDate,data=apple_steps_df, FUN=mean) 

merged=merge(apple_hr_df,apple_energy_df,by.x="apple_hr_startDate",by.y="apple_energy_startDate",all=TRUE)
merged=merge(merged,apple_steps_df,by.x="apple_hr_startDate",by.y="apple_steps_startDate",all=TRUE)
merged=subset(merged,select=c("apple_hr_startDate","apple_hr","apple_energy","apple_steps"))
names(merged)=c("Date","apple_hr","apple_energy","apple_steps")
apple=merged
write.table(apple,file=paste("apple_",subjectnum,".tsv",sep=""),sep='\t',row.names = FALSE)
