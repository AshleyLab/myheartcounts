rm(list=ls())
library(XML)
library(ggplot2)
library(reshape2)
library(scales)
Sys.setenv(TZ='GMT')

subject_dir="/home/anna/scg3/subject4/"
first=as.POSIXct(strptime(as.character("20150917180500"),"%Y%m%d%H%M%S"),tz="PDT")
last=as.POSIXct(strptime(as.character(" 20150917185000"),"%Y%m%d%H%M%S"),tz="PDT")

#READ IN STATE CHANGES FILE (i.e. START AND END TIME FOR EACH ACTIVITY)
states=data.frame(read.table(paste(subject_dir,"states_4.tsv",sep=""),header=T,sep='\t',stringsAsFactors=FALSE,row.names=1))
states$startTime=strptime(as.character(states$startTime),"%Y%m%d%H%M%S")
states$endTime=strptime(as.character(states$endTime),"%Y%m%d%H%M%S")
states$startTime=as.POSIXct(states$startTime,tz="PDT")
states$endTime=as.POSIXct(states$endTime,tz="PDT")

#READ IN GOLD STANDARD DATA 
gold_standard_det=data.frame(read.table(paste(subject_dir,"gold_standard_details_4.tsv",sep=""),header=T,sep='\t',stringsAsFactors = FALSE))
names(gold_standard_det)=c("gold_standard_startDate","gold_standard_hr","gold_standard_energy")
gold_standard_det$gold_standard_startDate=strptime(as.character(gold_standard_det$gold_standard_startDate),"%Y%m%d%H%M%S")
gold_standard_det$gold_standard_startDate=as.POSIXct(gold_standard_det$gold_standard_startDate,tz="PDT")

#READ IN BASIS DATA 
basis=data.frame(read.table(paste(subject_dir,"basis_4.tsv",sep=""),sep="\t",header=T,stringsAsFactors = FALSE))
names(basis)=c("basis_startDate","basis_energy", "basis_gsr","basis_hr","basis_temp","basis_steps")
basis$basis_startDate=as.POSIXct(strptime(as.character(basis$basis_startDate),"%Y%m%d%H%M%S"),tz="PDT")
basis$basis_startDate=basis$basis_startDate-2*60

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
apple_xml=xmlToList(xmlParse(paste(subject_dir,"export_4.xml",sep="")))
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
apple_hr_df$apple_hr_endDate=apple_hr_df$apple_hr_endDate-2*60
apple_hr_df$apple_hr_startDate=apple_hr_df$apple_hr_startDate-2*60
apple_hr_df=apple_hr_df[(apple_hr_df$apple_hr_startDate >=first) & (apple_hr_df$apple_hr_endDate<=last),]
apple_hr_df=aggregate(apple_hr~apple_hr_startDate+apple_hr_endDate,data=apple_hr_df, FUN=mean) 

apple_energy_df=data.frame(apple_energy,apple_energy_startDate,apple_energy_endDate)
apple_energy_df$apple_energy_startDate=strptime(as.character(apple_energy_df$apple_energy_startDate),"%Y%m%d%H%M")
apple_energy_df$apple_energy_endDate=strptime(as.character(apple_energy_df$apple_energy_endDate),"%Y%m%d%H%M")
apple_energy_df$apple_energy_startDate=as.POSIXct(apple_energy_df$apple_energy_startDate,tz="PDT")
apple_energy_df$apple_energy_endDate=as.POSIXct(apple_energy_df$apple_energy_endDate,tz="PDT")
apple_energy_df$apple_energy_endDate=apple_energy_df$apple_energy_endDate-60
apple_energy_df$apple_energy_startDate=apple_energy_df$apple_energy_startDate-60
apple_energy_df=apple_energy_df[(apple_energy_df$apple_energy_startDate >=first) & (apple_energy_df$apple_energy_endDate<=last),]
apple_energy_df=aggregate(apple_energy~apple_energy_startDate+apple_energy_endDate,data=apple_energy_df, FUN=mean) 

apple_steps_df=data.frame(apple_steps,apple_steps_startDate,apple_steps_endDate)
apple_steps_df$apple_steps_startDate=strptime(as.character(apple_steps_df$apple_steps_startDate),"%Y%m%d%H%M")
apple_steps_df$apple_steps_endDate=strptime(as.character(apple_steps_df$apple_steps_endDate),"%Y%m%d%H%M")
apple_steps_df$apple_steps_startDate=as.POSIXct(apple_steps_df$apple_steps_startDate,tz="PDT")
apple_steps_df$apple_steps_endDate=as.POSIXct(apple_steps_df$apple_steps_endDate,tz="PDT")
apple_steps_df$apple_steps_endDate=apple_steps_df$apple_steps_endDate-60
apple_steps_df$apple_steps_startDate=apple_steps_df$apple_steps_startDate-60
apple_steps_df=apple_steps_df[(apple_steps_df$apple_steps_startDate >=first) & (apple_steps_df$apple_steps_endDate<=last),]
apple_steps_df=aggregate(apple_steps~apple_steps_startDate+apple_steps_endDate,data=apple_steps_df, FUN=mean) 

#FITBIT DATA 
fitbit=data.frame(read.table(paste(subject_dir,"fitbit_4.tsv",sep=""),sep='\t',header=TRUE,stringsAsFactors = FALSE))
fitbit$Date=as.POSIXct(strptime(fitbit$Date,"%Y%m%d%H%M%S"),tz="PDT")
names(fitbit)=c("fitbit_date","fitbit_hr","fitbit_energy","fitbit_steps")
fitbit$fitbit_date=fitbit$fitbit_date-2*60

#MICROSOFT DATA
microsoft=data.frame(read.table(paste(subject_dir,"microsoft_4.tsv",sep=""),sep="\t",header=TRUE,stringsAsFactors = FALSE))
microsoft$Time=as.POSIXct(strptime(microsoft$Time,"%Y%m%d%H%M%S"),tz="PDT")
names(microsoft)=c("microsoft_date","microsoft_hr","microsoft_energy","microsoft_steps")
microsoft$microsoft_date=microsoft$microsoft_date-2*60

#BIN THE DATA BY ACTIVITY TYPE 
merged=merge(basis,apple_hr_df,by.x="basis_startDate",by.y="apple_hr_startDate",all=TRUE)
merged=merge(merged,gold_standard_det,by.x="basis_startDate",by.y="gold_standard_startDate",all=TRUE)
merged=merge(merged,apple_energy_df,by.x="basis_startDate",by.y="apple_energy_startDate",all=TRUE)
merged=merge(merged,apple_steps_df,by.x="basis_startDate",by.y="apple_steps_startDate",all=TRUE)
merged=merge(merged,fitbit,by.x="basis_startDate",by.y="fitbit_date",all=TRUE)
merged=merge(merged,microsoft,by.x="basis_startDate",by.y="microsoft_date",all=TRUE)


#PLOT!! 
mdf<- melt(merged, id="basis_startDate",measure=c("apple_hr","basis_hr","gold_standard_hr","fitbit_hr","microsoft_hr"))  # convert to long format
p=ggplot(data=mdf,
         aes(basis_startDate, y=value, colour=variable)) +
  geom_line() +geom_point(data=states,aes(endTime,HR,color="gold_standard_hr_steady_state"),size=5)+
  theme_bw(20)+theme(axis.text = element_text(size = 18),
                     legend.key = element_rect(fill = "navy"),
                     legend.text=element_text(size=18),
                     legend.background = element_rect(fill = "white"),
                     legend.position = c(0.14, 0.80),
                     panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(),
                     axis.title=element_text(size=18,face="bold"))+
  annotate("text", x = states$startTime+50, y = rep(200,length(states$startTime)), label = rownames(states),size=8)+
  xlab("Time")+ylab("Heart Rate (bpm)")+
  scale_fill_discrete(name="Device")+
  geom_vline(data=states, linetype=4, aes(xintercept=as.numeric(endTime)) )+
  scale_color_manual(values=c("#FF0000", "#66FF33", "#0000FF","#CC9900","#CC9900","#BDA0CB"))+
  xlim(c(first,last))

p
browser() 
merged$fitbit_energy
mdf<- melt(merged, id="basis_startDate",measure=c("apple_energy","basis_energy","gold_standard_energy","fitbit_energy", "microsoft_energy"))  # convert to long format
gold_standard=data.frame(read.table("gold_standard_subject3.tsv",header=T,sep='\t',stringsAsFactors = FALSE))
gold_standard$Time=strptime(as.character(gold_standard$Time),"%Y%m%d%H%M%S")
gold_standard$Time=as.POSIXct(gold_standard$Time,tz="PDT")
#first=as.POSIXct(strptime(as.character("20150908184200"),"%Y%m%d%H%M%S"),tz="PDT")
#last=as.POSIXct(strptime(as.character("20150908193200"),"%Y%m%d%H%M%S"),tz="PDT")

p=ggplot(data=mdf,
         aes(x=basis_startDate, y=value, colour=variable)) + 
  geom_line() +
  geom_point(data=states,aes(endTime,Energy,color="gold_standard_energy_steady_state"),size=5)+
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


mdf<- melt(merged, id="basis_startDate",measure=c("apple_steps","basis_steps","fitbit_steps","microsoft_steps"))  # convert to long format
#mdf$date=strptime(as.character(mdf$date),"%Y-%m-%d %H:%M")
#first=as.POSIXct(strptime(as.character("20150908184200"),"%Y%m%d%H%M%S"),tz="PDT")
#last=as.POSIXct(strptime(as.character("20150908193200"),"%Y%m%d%H%M%S"),tz="PDT")

p=ggplot(data=mdf,
         aes(x=basis_startDate, y=value, colour=variable))+ 
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

#SITTING 
sit1_start=states['Sit1','startTime']
sit1_end=states['Sit1','endTime']
sit2_start=states['Sit2','startTime']
sit2_end=states['Sit2','endTime']
sit3_start=states['Sit3','startTime']
sit3_end=states['Sit3','endTime']
sit1_data=merged[which((merged$basis_startDate >=sit1_start) & (merged$basis_startDate <=sit1_end)),]
sit2_data=merged[which((merged$basis_startDate >=sit2_start) & (merged$basis_startDate <=sit2_end)),]
sit3_data=merged[which((merged$basis_startDate >=sit3_start) & (merged$basis_startDate <=sit3_end)),]
sit_data=rbind(sit1_data,sit2_data,sit3_data)

#STANDING 

#RUNNING 
run1_start=states['Run1','startTime']
run1_end=states['Run1','endTime']
run2_start=states['Run2','startTime']
run2_end=states['Run2','endTime']
run1_data=merged[which((merged$basis_startDate >=run1_start) & (merged$basis_startDate <=run1_end)),]
run2_data=merged[which((merged$basis_startDate >=run2_start) & (merged$basis_startDate <=run2_end)),]
run_data=rbind(run1_data,run2_data)

#WALKING 
walk1_start=states['Walk1','startTime']
walk1_end=states['Walk1','endTime']
walk2_start=states['Walk2','startTime']
walk2_end=states['Walk2','endTime']
walk1_data=merged[which((merged$basis_startDate >=walk1_start) & (merged$basis_startDate <=walk1_end)),]
walk2_data=merged[which((merged$basis_startDate >=walk2_start) & (merged$basis_startDate <=walk2_end)),]
walk_data=rbind(walk1_data,walk2_data)

#CYCLING 
bike1_start=states['Bike1','startTime']
bike1_end=states['Bike1','endTime']
bike2_start=states['Bike2','startTime']
bike2_end=states['Bike2','endTime']
bike1_data=merged[which((merged$basis_startDate >=bike1_start) & (merged$basis_startDate <=bike1_end)),]
bike2_data=merged[which((merged$basis_startDate >=bike2_start) & (merged$basis_startDate <=bike2_end)),]
bike_data=rbind(bike1_data,bike2_data)


#MAX 
max_start=states['Max','startTime']
max_end=states['Max','endTime']
max_data=merged[which((merged$basis_startDate >=max_start) & (merged$basis_startDate <=max_end)),]

#COMPARE INSTRUMENTS TO GOLD STANDARD 
#basis-sitting 
sit_basis_hr_diff_total = sum(abs(na.omit(sit_data$basis_hr-sit_data$gold_standard_hr)))
sit_percent_diff=abs(na.omit((sit_data$basis_hr-sit_data$gold_standard_hr)/sit_data$gold_standard_hr))
sit_basis_hr_num_high_diff=length(which(sit_percent_diff >=0.05))

sit_basis_hr_beatdiff_steady=abs(sit1_data[nrow(sit1_data),"basis_hr"]-sit1_data[nrow(sit1_data),"gold_standard_hr"])
sit_basis_hr_beatdiff_steady=sit_basis_hr_beatdiff_steady+abs(sit2_data[nrow(sit2_data),"basis_hr"]-sit2_data[nrow(sit2_data),"gold_standard_hr"])
sit_basis_hr_beatdiff_steady=sit_basis_hr_beatdiff_steady+abs(sit3_data[nrow(sit3_data),"basis_hr"]-sit3_data[nrow(sit3_data),"gold_standard_hr"])
sit_basis_hr_beatdiff_steady=sit_basis_hr_beatdiff_steady/3 

sit_basis_hr_percentdiff_steady=abs(sit1_data[nrow(sit1_data),"basis_hr"]-sit1_data[nrow(sit1_data),"gold_standard_hr"])/sit1_data[nrow(sit1_data),"gold_standard_hr"]
sit_basis_hr_percentdiff_steady=sit_basis_hr_percentdiff_steady+abs(sit2_data[nrow(sit2_data),"basis_hr"]-sit2_data[nrow(sit2_data),"gold_standard_hr"])/sit2_data[nrow(sit2_data),"gold_standard_hr"]
sit_basis_hr_percentdiff_steady=sit_basis_hr_percentdiff_steady+abs(sit3_data[nrow(sit3_data),"basis_hr"]-sit3_data[nrow(sit3_data),"gold_standard_hr"])/sit3_data[nrow(sit3_data),"gold_standard_hr"]
sit_basis_hr_percentdiff_steady=sit_basis_hr_percentdiff_steady/3

#basis-walking 
walk_basis_hr_diff_total = sum(abs(na.omit(walk_data$basis_hr-walk_data$gold_standard_hr)))
walk_percent_diff=abs(na.omit((walk_data$basis_hr-walk_data$gold_standard_hr)/walk_data$gold_standard_hr))
walk_basis_hr_num_high_diff=length(which(walk_percent_diff >=0.05))

walk_basis_hr_beatdiff_steady=abs(walk1_data[nrow(walk1_data),"basis_hr"]-walk1_data[nrow(walk1_data),"gold_standard_hr"])
walk_basis_hr_beatdiff_steady=walk_basis_hr_beatdiff_steady+abs(walk2_data[nrow(walk2_data),"basis_hr"]-walk2_data[nrow(walk2_data),"gold_standard_hr"])
walk_basis_hr_beatdiff_steady=walk_basis_hr_beatdiff_steady/2 

walk_basis_hr_percentdiff_steady=abs(walk1_data[nrow(walk1_data),"basis_hr"]-walk1_data[nrow(walk1_data),"gold_standard_hr"])/walk1_data[nrow(walk1_data),"gold_standard_hr"]
walk_basis_hr_percentdiff_steady=walk_basis_hr_percentdiff_steady+abs(walk2_data[nrow(walk2_data),"basis_hr"]-walk2_data[nrow(walk2_data),"gold_standard_hr"])/walk2_data[nrow(walk2_data),"gold_standard_hr"]
walk_basis_hr_percentdiff_steady=walk_basis_hr_percentdiff_steady/2

#basis-running 
run_basis_hr_diff_total = sum(abs(na.omit(run_data$basis_hr-run_data$gold_standard_hr)))
run_percent_diff=abs(na.omit((run_data$basis_hr-run_data$gold_standard_hr)/run_data$gold_standard_hr))
run_basis_hr_num_high_diff=length(which(run_percent_diff >=0.05))

run_basis_hr_beatdiff_steady=abs(run1_data[nrow(run1_data),"basis_hr"]-run1_data[nrow(run1_data),"gold_standard_hr"])
run_basis_hr_beatdiff_steady=run_basis_hr_beatdiff_steady+abs(run2_data[nrow(run2_data),"basis_hr"]-run2_data[nrow(run2_data),"gold_standard_hr"])
run_basis_hr_beatdiff_steady=run_basis_hr_beatdiff_steady/2 

run_basis_hr_percentdiff_steady=abs(run1_data[nrow(run1_data),"basis_hr"]-run1_data[nrow(run1_data),"gold_standard_hr"])/run1_data[nrow(run1_data),"gold_standard_hr"]
run_basis_hr_percentdiff_steady=run_basis_hr_percentdiff_steady+abs(run2_data[nrow(run2_data),"basis_hr"]-run2_data[nrow(run2_data),"gold_standard_hr"])/run2_data[nrow(run2_data),"gold_standard_hr"]
run_basis_hr_percentdiff_steady=run_basis_hr_percentdiff_steady/2

#basis-cycling 
bike_basis_hr_diff_total = sum(abs(na.omit(bike_data$basis_hr-bike_data$gold_standard_hr)))
bike_percent_diff=abs(na.omit((bike_data$basis_hr-bike_data$gold_standard_hr)/bike_data$gold_standard_hr))
bike_basis_hr_num_high_diff=length(which(bike_percent_diff >=0.05))

bike_basis_hr_beatdiff_steady=abs(bike1_data[nrow(bike1_data),"basis_hr"]-bike1_data[nrow(bike1_data),"gold_standard_hr"])
bike_basis_hr_beatdiff_steady=bike_basis_hr_beatdiff_steady+abs(bike2_data[nrow(bike2_data),"basis_hr"]-bike2_data[nrow(bike2_data),"gold_standard_hr"])
bike_basis_hr_beatdiff_steady=bike_basis_hr_beatdiff_steady/2 

bike_basis_hr_percentdiff_steady=abs(bike1_data[nrow(bike1_data),"basis_hr"]-bike1_data[nrow(bike1_data),"gold_standard_hr"])/bike1_data[nrow(bike1_data),"gold_standard_hr"]
bike_basis_hr_percentdiff_steady=bike_basis_hr_percentdiff_steady+abs(bike2_data[nrow(bike2_data),"basis_hr"]-bike2_data[nrow(bike2_data),"gold_standard_hr"])/bike2_data[nrow(bike2_data),"gold_standard_hr"]
bike_basis_hr_percentdiff_steady=bike_basis_hr_percentdiff_steady/2

#basis-max 
max_basis_hr_diff_total = sum(abs(na.omit(max_data$basis_hr-max_data$gold_standard_hr)))
max_percent_diff=abs(na.omit((max_data$basis_hr-max_data$gold_standard_hr)/max_data$gold_standard_hr))
max_basis_hr_num_high_diff=length(which(max_percent_diff >=0.05))
max_basis_hr_beatdiff_steady=abs(max_data[nrow(max_data),"basis_hr"]-max_data[nrow(max_data),"gold_standard_hr"])
max_basis_hr_percentdiff_steady=abs(max_data[nrow(max_data),"basis_hr"]-max_data[nrow(max_data),"gold_standard_hr"])/max_data[nrow(max_data),"gold_standard_hr"]


#apple-sitting 
sit_apple_hr_diff_total = sum(abs(na.omit(sit_data$apple_hr-sit_data$gold_standard_hr)))
sit_percent_diff=abs(na.omit((sit_data$apple_hr-sit_data$gold_standard_hr)/sit_data$gold_standard_hr))
sit_apple_hr_num_high_diff=length(which(sit_percent_diff >=0.05))

sit_apple_hr_beatdiff_steady=abs(sit1_data[nrow(sit1_data),"apple_hr"]-sit1_data[nrow(sit1_data),"gold_standard_hr"])
sit_apple_hr_beatdiff_steady=sit_apple_hr_beatdiff_steady+abs(sit2_data[nrow(sit2_data),"apple_hr"]-sit2_data[nrow(sit2_data),"gold_standard_hr"])
sit_apple_hr_beatdiff_steady=sit_apple_hr_beatdiff_steady+abs(sit3_data[nrow(sit3_data),"apple_hr"]-sit3_data[nrow(sit3_data),"gold_standard_hr"])
sit_apple_hr_beatdiff_steady=sit_apple_hr_beatdiff_steady/3 

sit_apple_hr_percentdiff_steady=abs(sit1_data[nrow(sit1_data),"apple_hr"]-sit1_data[nrow(sit1_data),"gold_standard_hr"])/sit1_data[nrow(sit1_data),"gold_standard_hr"]
sit_apple_hr_percentdiff_steady=sit_apple_hr_percentdiff_steady+abs(sit2_data[nrow(sit2_data),"apple_hr"]-sit2_data[nrow(sit2_data),"gold_standard_hr"])/sit2_data[nrow(sit2_data),"gold_standard_hr"]
sit_apple_hr_percentdiff_steady=sit_apple_hr_percentdiff_steady+abs(sit3_data[nrow(sit3_data),"apple_hr"]-sit3_data[nrow(sit3_data),"gold_standard_hr"])/sit3_data[nrow(sit3_data),"gold_standard_hr"]
sit_apple_hr_percentdiff_steady=sit_apple_hr_percentdiff_steady/3

#apple-walking 
walk_apple_hr_diff_total = sum(abs(na.omit(walk_data$apple_hr-walk_data$gold_standard_hr)))
walk_percent_diff=abs(na.omit((walk_data$apple_hr-walk_data$gold_standard_hr)/walk_data$gold_standard_hr))
walk_apple_hr_num_high_diff=length(which(walk_percent_diff >=0.05))

walk_apple_hr_beatdiff_steady=abs(walk1_data[nrow(walk1_data),"apple_hr"]-walk1_data[nrow(walk1_data),"gold_standard_hr"])
walk_apple_hr_beatdiff_steady=walk_apple_hr_beatdiff_steady+abs(walk2_data[nrow(walk2_data),"apple_hr"]-walk2_data[nrow(walk2_data),"gold_standard_hr"])
walk_apple_hr_beatdiff_steady=walk_apple_hr_beatdiff_steady/2 

walk_apple_hr_percentdiff_steady=abs(walk1_data[nrow(walk1_data),"apple_hr"]-walk1_data[nrow(walk1_data),"gold_standard_hr"])/walk1_data[nrow(walk1_data),"gold_standard_hr"]
walk_apple_hr_percentdiff_steady=walk_apple_hr_percentdiff_steady+abs(walk2_data[nrow(walk2_data),"apple_hr"]-walk2_data[nrow(walk2_data),"gold_standard_hr"])/walk2_data[nrow(walk2_data),"gold_standard_hr"]
walk_apple_hr_percentdiff_steady=walk_apple_hr_percentdiff_steady/2

#apple-running 
run_apple_hr_diff_total = sum(abs(na.omit(run_data$apple_hr-run_data$gold_standard_hr)))
run_percent_diff=abs(na.omit((run_data$apple_hr-run_data$gold_standard_hr)/run_data$gold_standard_hr))
run_apple_hr_num_high_diff=length(which(run_percent_diff >=0.05))

run_apple_hr_beatdiff_steady=abs(run1_data[nrow(run1_data),"apple_hr"]-run1_data[nrow(run1_data),"gold_standard_hr"])
run_apple_hr_beatdiff_steady=run_apple_hr_beatdiff_steady+abs(run2_data[nrow(run2_data),"apple_hr"]-run2_data[nrow(run2_data),"gold_standard_hr"])
run_apple_hr_beatdiff_steady=run_apple_hr_beatdiff_steady/2 

run_apple_hr_percentdiff_steady=abs(run1_data[nrow(run1_data),"apple_hr"]-run1_data[nrow(run1_data),"gold_standard_hr"])/run1_data[nrow(run1_data),"gold_standard_hr"]
run_apple_hr_percentdiff_steady=run_apple_hr_percentdiff_steady+abs(run2_data[nrow(run2_data),"apple_hr"]-run2_data[nrow(run2_data),"gold_standard_hr"])/run2_data[nrow(run2_data),"gold_standard_hr"]
run_apple_hr_percentdiff_steady=run_apple_hr_percentdiff_steady/2

#apple-cycling 
bike_apple_hr_diff_total = sum(abs(na.omit(bike_data$apple_hr-bike_data$gold_standard_hr)))
bike_percent_diff=abs(na.omit((bike_data$apple_hr-bike_data$gold_standard_hr)/bike_data$gold_standard_hr))
bike_apple_hr_num_high_diff=length(which(bike_percent_diff >=0.05))

bike_apple_hr_beatdiff_steady=abs(bike1_data[nrow(bike1_data),"apple_hr"]-bike1_data[nrow(bike1_data),"gold_standard_hr"])
bike_apple_hr_beatdiff_steady=bike_apple_hr_beatdiff_steady+abs(bike2_data[nrow(bike2_data),"apple_hr"]-bike2_data[nrow(bike2_data),"gold_standard_hr"])
bike_apple_hr_beatdiff_steady=bike_apple_hr_beatdiff_steady/2 

bike_apple_hr_percentdiff_steady=abs(bike1_data[nrow(bike1_data),"apple_hr"]-bike1_data[nrow(bike1_data),"gold_standard_hr"])/bike1_data[nrow(bike1_data),"gold_standard_hr"]
bike_apple_hr_percentdiff_steady=bike_apple_hr_percentdiff_steady+abs(bike2_data[nrow(bike2_data),"apple_hr"]-bike2_data[nrow(bike2_data),"gold_standard_hr"])/bike2_data[nrow(bike2_data),"gold_standard_hr"]
bike_apple_hr_percentdiff_steady=bike_apple_hr_percentdiff_steady/2

#apple-max 
max_apple_hr_diff_total = sum(abs(na.omit(max_data$apple_hr-max_data$gold_standard_hr)))
max_percent_diff=abs(na.omit((max_data$apple_hr-max_data$gold_standard_hr)/max_data$gold_standard_hr))
max_apple_hr_num_high_diff=length(which(max_percent_diff >=0.05))
max_apple_hr_beatdiff_steady=abs(max_data[nrow(max_data),"apple_hr"]-max_data[nrow(max_data),"gold_standard_hr"])
max_apple_hr_percentdiff_steady=abs(max_data[nrow(max_data),"apple_hr"]-max_data[nrow(max_data),"gold_standard_hr"])/max_data[nrow(max_data),"gold_standard_hr"]

#SUMMARIZE THE RESULTS! 
hr_total_diff=c(sit_basis_hr_diff_total,walk_basis_hr_diff_total,run_basis_hr_diff_total,bike_basis_hr_diff_total,max_basis_hr_diff_total)
hr_total_diff_apple=c(sit_apple_hr_diff_total,walk_apple_hr_diff_total,run_apple_hr_diff_total,bike_apple_hr_diff_total,max_apple_hr_diff_total)

hr_num_high_diff=c(sit_basis_hr_num_high_diff,walk_basis_hr_num_high_diff,run_basis_hr_num_high_diff,bike_basis_hr_num_high_diff,max_basis_hr_num_high_diff)
hr_num_high_diff_apple=c(sit_apple_hr_num_high_diff,walk_apple_hr_num_high_diff,run_apple_hr_num_high_diff,bike_apple_hr_num_high_diff,max_apple_hr_num_high_diff)

hr_steady_diff=c(sit_basis_hr_beatdiff_steady,walk_basis_hr_beatdiff_steady,run_basis_hr_beatdiff_steady,bike_basis_hr_beatdiff_steady,max_basis_hr_beatdiff_steady)
hr_steady_diff_apple=c(sit_apple_hr_beatdiff_steady,walk_apple_hr_beatdiff_steady,run_apple_hr_beatdiff_steady,bike_apple_hr_beatdiff_steady,max_apple_hr_beatdiff_steady)

hr_steady_percent_diff=c(sit_basis_hr_percentdiff_steady,walk_basis_hr_percentdiff_steady,run_basis_hr_percentdiff_steady,bike_basis_hr_percentdiff_steady,max_basis_hr_percentdiff_steady)
hr_steady_percent_diff_apple=c(sit_apple_hr_percentdiff_steady,walk_apple_hr_percentdiff_steady,run_apple_hr_percentdiff_steady,bike_apple_hr_percentdiff_steady,max_apple_hr_percentdiff_steady)

basis_df=data.frame(hr_total_diff,hr_num_high_diff,hr_steady_diff,hr_steady_percent_diff,rep("Basis",5),c("Sit","Walk","Run","Bike","Max"))
apple_df=data.frame(hr_total_diff_apple,hr_num_high_diff_apple,hr_steady_diff_apple,hr_steady_percent_diff_apple,rep("Apple",5),c("Sit","Walk","Run","Bike","Max"))
names(basis_df)=c("DeltaBeats","MinutesHighDiff","SteadyStateDeltaBeats","SteadyStateDeltaPercent","Device","State")
names(apple_df)=c("DeltaBeats","MinutesHighDiff","SteadyStateDeltaBeats","SteadyStateDeltaPercent","Device","State")
hr_dif=rbind(basis_df,apple_df)
hr_dif$State=factor(hr_dif$State,levels=c("Sit","Walk","Run","Bike","Max"))
hr_dif$SteadyStateDeltaPercent=hr_dif$SteadyStateDeltaPercent*100
#PLOT! 
png("hr_total_bpm.png")
ggplot(data=hr_dif, aes(x=State, y=DeltaBeats, fill=Device)) +
  geom_bar(position="dodge",stat="identity")+ ylab("Total difference in bpm\n(integrated across time interval)")+
  theme_bw(20)
dev.off() 

png("hr_minutes.png")
ggplot(data=hr_dif, aes(x=State, y=MinutesHighDiff, fill=Device)) +
  geom_bar(position="dodge",stat="identity")+ ylab("Number of min. when device\ndiffered from GS by >=5%")+
  theme_bw(20)
dev.off() 

png("hr_steady_state_bpm.png")
ggplot(data=hr_dif, aes(x=State, y=SteadyStateDeltaBeats, fill=Device)) + ylab("Bpm diff from GS at steady state")+
  geom_bar(position="dodge",stat="identity")+ 
  theme_bw(20)
dev.off() 

png("hr_steady_state_percent.png")
ggplot(data=hr_dif, aes(x=State, y=SteadyStateDeltaPercent, fill=Device)) + ylab("Percent diff from GS at steady state")+
  geom_bar(position="dodge",stat="identity")+ 
  theme_bw(20)
dev.off() 

write.table(hr_dif,file="hr_diff.csv",sep='\t')

#CALORIES###################################################################################################################################################

#basis-sitting 
sit_basis_energy_diff_total = sum(abs(na.omit(sit_data$basis_energy-sit_data$gold_standard_energy)))
sit_percent_diff=abs(na.omit((sit_data$basis_energy-sit_data$gold_standard_energy)/sit_data$gold_standard_energy))
sit_basis_energy_num_high_diff=length(which(sit_percent_diff >=0.05))

sit_basis_energy_beatdiff_steady=abs(sit1_data[nrow(sit1_data),"basis_energy"]-sit1_data[nrow(sit1_data),"gold_standard_energy"])
sit_basis_energy_beatdiff_steady=sit_basis_energy_beatdiff_steady+abs(sit2_data[nrow(sit2_data),"basis_energy"]-sit2_data[nrow(sit2_data),"gold_standard_energy"])
sit_basis_energy_beatdiff_steady=sit_basis_energy_beatdiff_steady+abs(sit3_data[nrow(sit3_data),"basis_energy"]-sit3_data[nrow(sit3_data),"gold_standard_energy"])
sit_basis_energy_beatdiff_steady=sit_basis_energy_beatdiff_steady/3 

sit_basis_energy_percentdiff_steady=abs(sit1_data[nrow(sit1_data),"basis_energy"]-sit1_data[nrow(sit1_data),"gold_standard_energy"])/sit1_data[nrow(sit1_data),"gold_standard_energy"]
sit_basis_energy_percentdiff_steady=sit_basis_energy_percentdiff_steady+abs(sit2_data[nrow(sit2_data),"basis_energy"]-sit2_data[nrow(sit2_data),"gold_standard_energy"])/sit2_data[nrow(sit2_data),"gold_standard_energy"]
sit_basis_energy_percentdiff_steady=sit_basis_energy_percentdiff_steady+abs(sit3_data[nrow(sit3_data),"basis_energy"]-sit3_data[nrow(sit3_data),"gold_standard_energy"])/sit3_data[nrow(sit3_data),"gold_standard_energy"]
sit_basis_energy_percentdiff_steady=sit_basis_energy_percentdiff_steady/3

#basis-walking 
walk_basis_energy_diff_total = sum(abs(na.omit(walk_data$basis_energy-walk_data$gold_standard_energy)))
walk_percent_diff=abs(na.omit((walk_data$basis_energy-walk_data$gold_standard_energy)/walk_data$gold_standard_energy))
walk_basis_energy_num_high_diff=length(which(walk_percent_diff >=0.05))

walk_basis_energy_beatdiff_steady=abs(walk1_data[nrow(walk1_data),"basis_energy"]-walk1_data[nrow(walk1_data),"gold_standard_energy"])
walk_basis_energy_beatdiff_steady=walk_basis_energy_beatdiff_steady+abs(walk2_data[nrow(walk2_data),"basis_energy"]-walk2_data[nrow(walk2_data),"gold_standard_energy"])
walk_basis_energy_beatdiff_steady=walk_basis_energy_beatdiff_steady/2 

walk_basis_energy_percentdiff_steady=abs(walk1_data[nrow(walk1_data),"basis_energy"]-walk1_data[nrow(walk1_data),"gold_standard_energy"])/walk1_data[nrow(walk1_data),"gold_standard_energy"]
walk_basis_energy_percentdiff_steady=walk_basis_energy_percentdiff_steady+abs(walk2_data[nrow(walk2_data),"basis_energy"]-walk2_data[nrow(walk2_data),"gold_standard_energy"])/walk2_data[nrow(walk2_data),"gold_standard_energy"]
walk_basis_energy_percentdiff_steady=walk_basis_energy_percentdiff_steady/2

#basis-running 
run_basis_energy_diff_total = sum(abs(na.omit(run_data$basis_energy-run_data$gold_standard_energy)))
run_percent_diff=abs(na.omit((run_data$basis_energy-run_data$gold_standard_energy)/run_data$gold_standard_energy))
run_basis_energy_num_high_diff=length(which(run_percent_diff >=0.05))

run_basis_energy_beatdiff_steady=abs(run1_data[nrow(run1_data),"basis_energy"]-run1_data[nrow(run1_data),"gold_standard_energy"])
run_basis_energy_beatdiff_steady=run_basis_energy_beatdiff_steady+abs(run2_data[nrow(run2_data),"basis_energy"]-run2_data[nrow(run2_data),"gold_standard_energy"])
run_basis_energy_beatdiff_steady=run_basis_energy_beatdiff_steady/2 

run_basis_energy_percentdiff_steady=abs(run1_data[nrow(run1_data),"basis_energy"]-run1_data[nrow(run1_data),"gold_standard_energy"])/run1_data[nrow(run1_data),"gold_standard_energy"]
run_basis_energy_percentdiff_steady=run_basis_energy_percentdiff_steady+abs(run2_data[nrow(run2_data),"basis_energy"]-run2_data[nrow(run2_data),"gold_standard_energy"])/run2_data[nrow(run2_data),"gold_standard_energy"]
run_basis_energy_percentdiff_steady=run_basis_energy_percentdiff_steady/2

#basis-cycling 
bike_basis_energy_diff_total = sum(abs(na.omit(bike_data$basis_energy-bike_data$gold_standard_energy)))
bike_percent_diff=abs(na.omit((bike_data$basis_energy-bike_data$gold_standard_energy)/bike_data$gold_standard_energy))
bike_basis_energy_num_high_diff=length(which(bike_percent_diff >=0.05))

bike_basis_energy_beatdiff_steady=abs(bike1_data[nrow(bike1_data),"basis_energy"]-bike1_data[nrow(bike1_data),"gold_standard_energy"])
bike_basis_energy_beatdiff_steady=bike_basis_energy_beatdiff_steady+abs(bike2_data[nrow(bike2_data),"basis_energy"]-bike2_data[nrow(bike2_data),"gold_standard_energy"])
bike_basis_energy_beatdiff_steady=bike_basis_energy_beatdiff_steady/2 

bike_basis_energy_percentdiff_steady=abs(bike1_data[nrow(bike1_data),"basis_energy"]-bike1_data[nrow(bike1_data),"gold_standard_energy"])/bike1_data[nrow(bike1_data),"gold_standard_energy"]
bike_basis_energy_percentdiff_steady=bike_basis_energy_percentdiff_steady+abs(bike2_data[nrow(bike2_data),"basis_energy"]-bike2_data[nrow(bike2_data),"gold_standard_energy"])/bike2_data[nrow(bike2_data),"gold_standard_energy"]
bike_basis_energy_percentdiff_steady=bike_basis_energy_percentdiff_steady/2

#basis-max 
max_basis_energy_diff_total = sum(abs(na.omit(max_data$basis_energy-max_data$gold_standard_energy)))
max_percent_diff=abs(na.omit((max_data$basis_energy-max_data$gold_standard_energy)/max_data$gold_standard_energy))
max_basis_energy_num_high_diff=length(which(max_percent_diff >=0.05))
max_basis_energy_beatdiff_steady=abs(max_data[nrow(max_data),"basis_energy"]-max_data[nrow(max_data),"gold_standard_energy"])
max_basis_energy_percentdiff_steady=abs(max_data[nrow(max_data),"basis_energy"]-max_data[nrow(max_data),"gold_standard_energy"])/max_data[nrow(max_data),"gold_standard_energy"]


#apple-sitting 
sit_apple_energy_diff_total = sum(abs(na.omit(sit_data$apple_energy-sit_data$gold_standard_energy)))
sit_percent_diff=abs(na.omit((sit_data$apple_energy-sit_data$gold_standard_energy)/sit_data$gold_standard_energy))
sit_apple_energy_num_high_diff=length(which(sit_percent_diff >=0.05))

sit_apple_energy_beatdiff_steady=abs(sit1_data[nrow(sit1_data),"apple_energy"]-sit1_data[nrow(sit1_data),"gold_standard_energy"])
sit_apple_energy_beatdiff_steady=sit_apple_energy_beatdiff_steady+abs(sit2_data[nrow(sit2_data),"apple_energy"]-sit2_data[nrow(sit2_data),"gold_standard_energy"])
sit_apple_energy_beatdiff_steady=sit_apple_energy_beatdiff_steady+abs(sit3_data[nrow(sit3_data),"apple_energy"]-sit3_data[nrow(sit3_data),"gold_standard_energy"])
sit_apple_energy_beatdiff_steady=sit_apple_energy_beatdiff_steady/3 

sit_apple_energy_percentdiff_steady=abs(sit1_data[nrow(sit1_data),"apple_energy"]-sit1_data[nrow(sit1_data),"gold_standard_energy"])/sit1_data[nrow(sit1_data),"gold_standard_energy"]
sit_apple_energy_percentdiff_steady=sit_apple_energy_percentdiff_steady+abs(sit2_data[nrow(sit2_data),"apple_energy"]-sit2_data[nrow(sit2_data),"gold_standard_energy"])/sit2_data[nrow(sit2_data),"gold_standard_energy"]
sit_apple_energy_percentdiff_steady=sit_apple_energy_percentdiff_steady+abs(sit3_data[nrow(sit3_data),"apple_energy"]-sit3_data[nrow(sit3_data),"gold_standard_energy"])/sit3_data[nrow(sit3_data),"gold_standard_energy"]
sit_apple_energy_percentdiff_steady=sit_apple_energy_percentdiff_steady/3

#apple-walking 
walk_apple_energy_diff_total = sum(abs(na.omit(walk_data$apple_energy-walk_data$gold_standard_energy)))
walk_percent_diff=abs(na.omit((walk_data$apple_energy-walk_data$gold_standard_energy)/walk_data$gold_standard_energy))
walk_apple_energy_num_high_diff=length(which(walk_percent_diff >=0.05))

walk_apple_energy_beatdiff_steady=abs(walk1_data[nrow(walk1_data),"apple_energy"]-walk1_data[nrow(walk1_data),"gold_standard_energy"])
walk_apple_energy_beatdiff_steady=walk_apple_energy_beatdiff_steady+abs(walk2_data[nrow(walk2_data),"apple_energy"]-walk2_data[nrow(walk2_data),"gold_standard_energy"])
walk_apple_energy_beatdiff_steady=walk_apple_energy_beatdiff_steady/2 

walk_apple_energy_percentdiff_steady=abs(walk1_data[nrow(walk1_data),"apple_energy"]-walk1_data[nrow(walk1_data),"gold_standard_energy"])/walk1_data[nrow(walk1_data),"gold_standard_energy"]
walk_apple_energy_percentdiff_steady=walk_apple_energy_percentdiff_steady+abs(walk2_data[nrow(walk2_data),"apple_energy"]-walk2_data[nrow(walk2_data),"gold_standard_energy"])/walk2_data[nrow(walk2_data),"gold_standard_energy"]
walk_apple_energy_percentdiff_steady=walk_apple_energy_percentdiff_steady/2

#apple-running 
run_apple_energy_diff_total = sum(abs(na.omit(run_data$apple_energy-run_data$gold_standard_energy)))
run_percent_diff=abs(na.omit((run_data$apple_energy-run_data$gold_standard_energy)/run_data$gold_standard_energy))
run_apple_energy_num_high_diff=length(which(run_percent_diff >=0.05))

run_apple_energy_beatdiff_steady=abs(run1_data[nrow(run1_data),"apple_energy"]-run1_data[nrow(run1_data),"gold_standard_energy"])
run_apple_energy_beatdiff_steady=run_apple_energy_beatdiff_steady+abs(run2_data[nrow(run2_data),"apple_energy"]-run2_data[nrow(run2_data),"gold_standard_energy"])
run_apple_energy_beatdiff_steady=run_apple_energy_beatdiff_steady/2 

run_apple_energy_percentdiff_steady=abs(run1_data[nrow(run1_data),"apple_energy"]-run1_data[nrow(run1_data),"gold_standard_energy"])/run1_data[nrow(run1_data),"gold_standard_energy"]
run_apple_energy_percentdiff_steady=run_apple_energy_percentdiff_steady+abs(run2_data[nrow(run2_data),"apple_energy"]-run2_data[nrow(run2_data),"gold_standard_energy"])/run2_data[nrow(run2_data),"gold_standard_energy"]
run_apple_energy_percentdiff_steady=run_apple_energy_percentdiff_steady/2

#apple-cycling 
bike_apple_energy_diff_total = sum(abs(na.omit(bike_data$apple_energy-bike_data$gold_standard_energy)))
bike_percent_diff=abs(na.omit((bike_data$apple_energy-bike_data$gold_standard_energy)/bike_data$gold_standard_energy))
bike_apple_energy_num_high_diff=length(which(bike_percent_diff >=0.05))

bike_apple_energy_beatdiff_steady=abs(bike1_data[nrow(bike1_data),"apple_energy"]-bike1_data[nrow(bike1_data),"gold_standard_energy"])
bike_apple_energy_beatdiff_steady=bike_apple_energy_beatdiff_steady+abs(bike2_data[nrow(bike2_data),"apple_energy"]-bike2_data[nrow(bike2_data),"gold_standard_energy"])
bike_apple_energy_beatdiff_steady=bike_apple_energy_beatdiff_steady/2 

bike_apple_energy_percentdiff_steady=abs(bike1_data[nrow(bike1_data),"apple_energy"]-bike1_data[nrow(bike1_data),"gold_standard_energy"])/bike1_data[nrow(bike1_data),"gold_standard_energy"]
bike_apple_energy_percentdiff_steady=bike_apple_energy_percentdiff_steady+abs(bike2_data[nrow(bike2_data),"apple_energy"]-bike2_data[nrow(bike2_data),"gold_standard_energy"])/bike2_data[nrow(bike2_data),"gold_standard_energy"]
bike_apple_energy_percentdiff_steady=bike_apple_energy_percentdiff_steady/2

#apple-max 
max_apple_energy_diff_total = sum(abs(na.omit(max_data$apple_energy-max_data$gold_standard_energy)))
max_percent_diff=abs(na.omit((max_data$apple_energy-max_data$gold_standard_energy)/max_data$gold_standard_energy))
max_apple_energy_num_high_diff=length(which(max_percent_diff >=0.05))
max_apple_energy_beatdiff_steady=abs(max_data[nrow(max_data),"apple_energy"]-max_data[nrow(max_data),"gold_standard_energy"])
max_apple_energy_percentdiff_steady=abs(max_data[nrow(max_data),"apple_energy"]-max_data[nrow(max_data),"gold_standard_energy"])/max_data[nrow(max_data),"gold_standard_energy"]

#SUMMARIZE THE RESULTS! 
energy_total_diff=c(sit_basis_energy_diff_total,walk_basis_energy_diff_total,run_basis_energy_diff_total,bike_basis_energy_diff_total,max_basis_energy_diff_total)
energy_total_diff_apple=c(sit_apple_energy_diff_total,walk_apple_energy_diff_total,run_apple_energy_diff_total,bike_apple_energy_diff_total,max_apple_energy_diff_total)

energy_num_high_diff=c(sit_basis_energy_num_high_diff,walk_basis_energy_num_high_diff,run_basis_energy_num_high_diff,bike_basis_energy_num_high_diff,max_basis_energy_num_high_diff)
energy_num_high_diff_apple=c(sit_apple_energy_num_high_diff,walk_apple_energy_num_high_diff,run_apple_energy_num_high_diff,bike_apple_energy_num_high_diff,max_apple_energy_num_high_diff)

energy_steady_diff=c(sit_basis_energy_beatdiff_steady,walk_basis_energy_beatdiff_steady,run_basis_energy_beatdiff_steady,bike_basis_energy_beatdiff_steady,max_basis_energy_beatdiff_steady)
energy_steady_diff_apple=c(sit_apple_energy_beatdiff_steady,walk_apple_energy_beatdiff_steady,run_apple_energy_beatdiff_steady,bike_apple_energy_beatdiff_steady,max_apple_energy_beatdiff_steady)

energy_steady_percent_diff=c(sit_basis_energy_percentdiff_steady,walk_basis_energy_percentdiff_steady,run_basis_energy_percentdiff_steady,bike_basis_energy_percentdiff_steady,max_basis_energy_percentdiff_steady)
energy_steady_percent_diff_apple=c(sit_apple_energy_percentdiff_steady,walk_apple_energy_percentdiff_steady,run_apple_energy_percentdiff_steady,bike_apple_energy_percentdiff_steady,max_apple_energy_percentdiff_steady)

basis_df=data.frame(energy_total_diff,energy_num_high_diff,energy_steady_diff,energy_steady_percent_diff,rep("Basis",5),c("Sit","Walk","Run","Bike","Max"))
apple_df=data.frame(energy_total_diff_apple,energy_num_high_diff_apple,energy_steady_diff_apple,energy_steady_percent_diff_apple,rep("Apple",5),c("Sit","Walk","Run","Bike","Max"))
names(basis_df)=c("DeltaKcal","MinutesHighDiff","SteadyStateDeltaKcal","SteadyStateDeltaPercent","Device","State")
names(apple_df)=c("DeltaKcal","MinutesHighDiff","SteadyStateDeltaKcal","SteadyStateDeltaPercent","Device","State")
energy_dif=rbind(basis_df,apple_df)
energy_dif$State=factor(energy_dif$State,levels=c("Sit","Walk","Run","Bike","Max"))
energy_dif$SteadyStateDeltaPercent=energy_dif$SteadyStateDeltaPercent*100
#PLOT! 
png("energy_total_bpm.png")
ggplot(data=energy_dif, aes(x=State, y=DeltaKcal, fill=Device)) +
  geom_bar(position="dodge",stat="identity")+ ylab("Total difference in kcal\n(integrated across time interval)")+
  theme_bw(20)
dev.off() 

png("energy_minutes.png")
ggplot(data=energy_dif, aes(x=State, y=MinutesHighDiff, fill=Device)) +
  geom_bar(position="dodge",stat="identity")+ ylab("Number of min. when device\ndiffered from GS by >=5%")+
  theme_bw(20)
dev.off() 

png("energy_steady_state_bpm.png")
ggplot(data=energy_dif, aes(x=State, y=SteadyStateDeltaKcal, fill=Device)) + ylab("Kcal diff from GS at steady state")+
  geom_bar(position="dodge",stat="identity")+ 
  theme_bw(20)
dev.off() 

png("energy_steady_state_percent.png")
ggplot(data=energy_dif, aes(x=State, y=SteadyStateDeltaPercent, fill=Device)) + ylab("Percent diff from GS at steady state")+
  geom_bar(position="dodge",stat="identity")+ 
  theme_bw(20)
dev.off() 

write.table(energy_dif,file="energy_diff.csv",sep='\t')
