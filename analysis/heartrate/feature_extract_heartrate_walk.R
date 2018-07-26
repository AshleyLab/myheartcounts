rm(list=ls())
library(wavelets) 
library(data.table)
source('helpers.R') 
source('parameters.R') 

args <- commandArgs(trailingOnly = TRUE)
#get the metadata to determine Age for heart rate zone determination 
metaf=data.frame(read.table(metadata,header=T,sep="\t",skip = 1,row.names=1))
#############################################################################################
#extract features for acceleration walk
gotfirst=FALSE
files <- list.files(path=hr_walk_dir, pattern="*.tsv", full.names=T, recursive=FALSE)
skipped=0 
for (i in 1:length(files)){
    success<-FALSE
    #STORE THE COEFFICIENTS IN THE FEATURE MATRIX THAT WE ARE BUILDING
    cur_subject<-strsplit(files[i],"/")[[1]]
    cur_subject<-cur_subject[length(cur_subject)]
    
    #get the number of steps! 
    if (file.exists(paste(pedometer_dir,cur_subject,sep="/"))==FALSE)
    {
      print("SKIPPING!!")
      skipped=skipped+1 
      next 
    }
    steps=data.frame(read.table(paste(pedometer_dir,cur_subject,sep="/"),header=T,sep='\t',quote="\""),stringsAsFactors=FALSE)
    steps$startDate=strptime(as.character(steps$startDate),"%Y-%m-%dT%H:%M:%S")
    steps$endDate=strptime(as.character(steps$endDate),"%Y-%m-%dT%H:%M:%S")
    
    #subject's healthCode 
    cur_subject<-gsub(".tsv","",cur_subject)
    print(cur_subject) 
    cur_age=metaf[cur_subject,]$Age
   
    signal_walk<-as.data.frame(read.table(files[i],header=T,stringsAsFactors=FALSE,sep="\t",quote="\""))
    #convert to posix 
    signal_walk$startDate=strptime(as.character(signal_walk$startDate),"%Y-%m-%dT%H:%M:%S")
    signal_walk$endDate=strptime(as.character(signal_walk$endDate),"%Y-%m-%dT%H:%M:%S")
    delta=as.numeric(difftime(max(signal_walk$startDate),min(signal_walk$startDate),units="secs")) 

    #Need at least 4 minutes of data ! 
    if(delta < 180) 
    {
      skipped=skipped+1 
      next
    }
    if(nrow(signal_walk)<10)
    {
      skipped=skipped+1
      next 
    }
    #Get the statistics for heart rate 
    maxhr=NA
    if(is.na(cur_age)==FALSE)
      maxhr=191.5-(0.007*cur_age^2)
    
    #average velocity 
    speed=max(steps$distance)/as.numeric(max(steps$endDate-steps$startDate)) #m/s 
    
    #mean heart rate last minute 
    last_min_thresh=signal_walk$endDate-60 
    last_min=signal_walk[which(signal_walk$endDate > last_min_thresh),]
    last_min_hr=mean(last_min$value)
    
    if(is.na(maxhr)==FALSE)
    {
      delta_hr=maxhr-last_min_hr 
    }
    else
    {
      delta_hr=NA 
    }
    
    
    #Other statistics   
    num_entries=nrow(signal_walk)
    max_val=max(signal_walk$value)
    min_val=min(signal_walk$value)
    mean_val=mean(signal_walk$value)
    var_val = var(signal_walk$value)
    
    if(is.na(cur_age)==FALSE)
    {
    zones=getZone(cur_age)
    zlow_index=which(signal_walk$value < zones$z1[1])
    z1_index=which(signal_walk$value >= zones$z1[1] & signal_walk$value <= zones$z1[2])
    z2_index=which(signal_walk$value >= zones$z2[1] & signal_walk$value <= zones$z2[2])
    z3_index=which(signal_walk$value >= zones$z3[1] & signal_walk$value <= zones$z3[2])
    z4_index=which(signal_walk$value >= zones$z4[1] & signal_walk$value <= zones$z4[2])
    z5_index=which(signal_walk$value >= zones$z5[1] & signal_walk$value <= zones$z5[2])
    zhigh_index=which(signal_walk$value > zones$z5[2])
    intervals=diff(signal_walk$startDate)
    zlow_duration=sum(as.numeric(na.omit(intervals[zlow_index])))/delta
    z1_duration=sum(as.numeric(na.omit(intervals[z1_index])))/delta
    z2_duration=sum(as.numeric(na.omit(intervals[z2_index])))/delta
    z3_duration=sum(as.numeric(na.omit(intervals[z3_index])))/delta
    z4_duration=sum(as.numeric(na.omit(intervals[z4_index])))/delta
    z5_duration=sum(as.numeric(na.omit(intervals[z5_index])))/delta
    zhigh_duration=sum(as.numeric(na.omit(intervals[zhigh_index])))/delta
    }
    else
    {
      zlow_duration=NA
      z1_duration=NA
      z2_duration=NA
      z3_duration=NA
      z4_duration=NA
      z5_duration=NA 
      zhigh_duration=NA
    }
    
    #get the slope (delta in heart rate) for each minute (or NA if insufficient data collected)
    final=max(signal_walk$endDate)
    min1_max=signal_walk$startDate[1]+60
    if(min1_max > final)
      min1_max=NA 
    min2_max=signal_walk$startDate[1]+120
    if(min2_max > final)
    {
      min2_max=NA 
    }
    min3_max=signal_walk$startDate[1]+180 
    if(min3_max > final)
    {
      min3_max=NA
    }
    
    min4_max=signal_walk$startDate[1]+240 
    if(min4_max > final)
    {
      min4_max=NA 
    }
    
    min5_max=signal_walk$startDate[1]+300 
    if(min5_max > final)
    {
      min5_max=NA
    }
    
    min6_max=signal_walk$startDate[1]+360
    if(min6_max > final)
    {
      min6_max=NA 
    }

    start_hr=signal_walk$value[1]
    if(is.na(min1_max))
      delta1=NA
    else
    {
    min1_hr=signal_walk$value[max(which(signal_walk$startDate <=min1_max))]
    delta1=min1_hr-start_hr
    }
    
    if(is.na(min2_max))
      delta2=NA 
    else
    {
    min2_hr=signal_walk$value[max(which(signal_walk$startDate <=min2_max))]
    delta2=min2_hr-min1_hr
    }
    
    if(is.na(min3_max))
      delta3=NA 
    else
    {
      min3_hr=signal_walk$value[max(which(signal_walk$startDate <=min3_max))]
      delta3=min3_hr-min2_hr   
    }
    
    if(is.na(min4_max))
      delta4=NA 
    else
    {
      min4_hr=signal_walk$value[max(which(signal_walk$startDate <=min4_max))]
      delta4=min4_hr-min3_hr     
    }
    
    if(is.na(min5_max))
      delta5=NA 
    else
    {
      min5_hr=signal_walk$value[max(which(signal_walk$startDate <=min5_max))]
      delta5=min5_hr-min4_hr      
    }
    
    if(is.na(min6_max))
      delta6=NA 
    else
    {
    min6_hr=signal_walk$value[max(which(signal_walk$startDate <=min6_max))]
    delta6=min6_hr-min5_hr
    }
    
    if(gotfirst==FALSE)
    {
      result<-data.frame(t(c(delta,num_entries,max_val,min_val,var_val,zlow_duration,z1_duration,z2_duration,z3_duration,z4_duration,z5_duration,zhigh_duration,delta1,delta2,delta3,delta4,delta5,delta6,speed,last_min_hr,delta_hr,maxhr)),row.names=cur_subject)
      names(result)=c("DurationS","NumEntries","Max","Min","Var","zlow","z1","z2","z3","z4","z5","zhigh","delta1","delta2","delta3","delta4","delta5","delta6","speed","last_min_hr","delta_hr","max_pred_hr")
      gotfirst=TRUE
    }
    else
    {
      new_entry<-data.frame(t(c(delta,num_entries,max_val,min_val,var_val,zlow_duration,z1_duration,z2_duration,z3_duration,z4_duration,z5_duration,zhigh_duration,delta1,delta2,delta3,delta4,delta5,delta6,speed,last_min_hr,delta_hr,maxhr)),row.names=cur_subject)
      names(new_entry)=c("DurationS","NumEntries","Max","Min","Var","zlow","z1","z2","z3","z4","z5","zhigh","delta1","delta2","delta3","delta4","delta5","delta6","speed","last_min_hr","delta_hr","max_pred_hr")
      result<-rbind(result,new_entry)
    }
}
print("writing output binary hr walk  file") 
hr_walk=result
save(hr_walk,file="hr_walk.bin")