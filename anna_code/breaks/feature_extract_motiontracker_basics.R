rm(list=ls())
library(wavelets) 
library(data.table)
source('helpers.R')


#directories with acceleration data
weekday_dir<-'/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/weekday'
weekend_dir<-'/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/weekend'



#############################################################################################
#CREATE A DATA FRAME FOR FEATURE STORAGE
features<-data.frame(cur_subject=character(),
			   stationary_day=double,
		     stationary_end=double,
		     walking_day=double,
		     walking_end=double,
			   changes_day=integer,
			   changes_end=integer,
		     stringsAsFactors=FALSE)

#############################################################################################
#extract features for acceleration walk
args <- commandArgs(trailingOnly = TRUE)
startf<-args[1] 
endf<-args[2] 
numpoints=50
files <- list.files(path=weekday_dir, pattern="*.tsv", full.names=T, recursive=FALSE)
for (i in startf:endf){
    print(i) 
    signal_weekday<-as.data.frame(read.table(files[i],header=F,stringsAsFactors=FALSE,sep="\t"))
    weekend_file_name<-gsub("weekday","weekend",files[i])
    signal_weekend<-as.data.frame(read.table(weekend_file_name,header=F,stringsAsFactors=FALSE,sep="\t"))
    
    #COLLAPSE DATA TO 2 STATES -- ACTIVE(2) & INACTIVE (1)
    running=which(signal_weekday$V3 %in% 3)
    cycling=which(signal_weekday$V3 %in% 5)
    signal_weekday$V3[running]=2 
    signal_weekday$V3[cycling]=2 
    automotive=which(signal_weekday$V3 %in% 4)
    signal_weekday$V3[automotive]=1 
    #TAKE THE 100 point sliding window majority vote 
    signal_weekday$V3=majorityVote(signal_weekday$V3,numpoints)
    
    number_active=length(which(signal_weekday$V3 %in% 2))
    number_stationary=length(which(signal_weekday$V3 %in% 1)) 
    percent_active_weekday=number_active/(number_active+number_stationary)
    percent_stationary_weekday=number_stationary/(number_active+number_stationary)
    
    #GET THE NUMBER OF TRANSITIONS 
    no_transition=length(which(diff(signal_weekday$V3) %in%0))
    total_observations=length(diff(signal_weekday$V3))
    num_transitions_weekday=total_observations-no_transition 

    #REPEAT FOR THE WEEKEND DATA 

    #COLLAPSE DATA TO 2 STATES -- ACTIVE(2) & INACTIVE (1)
    running=which(signal_weekend$V3 %in% 3)
    cycling=which(signal_weekend$V3 %in% 5)
    signal_weekend$V3[running]=2 
    signal_weekend$V3[cycling]=2 
    automotive=which(signal_weekend$V3 %in% 4)
    signal_weekend$V3[automotive]=1 
    
    #TAKE THE 100 point sliding window majority vote 
    signal_weekend$V3=majorityVote(signal_weekend$V3,numpoints)
    
  
    number_active=length(which(signal_weekend$V3 %in% 2))
    number_stationary=length(which(signal_weekend$V3 %in% 1)) 
    percent_active_weekend=number_active/(number_active+number_stationary)
    percent_stationary_weekend=number_stationary/(number_active+number_stationary)
    
    #GET THE NUMBER OF TRANSITIONS 
    no_transition=length(which(diff(signal_weekend$V3) %in%0))
    total_observations=length(diff(signal_weekend$V3))
    num_transitions_weekend=total_observations-no_transition
  
	cur_subject<-strsplit(files[i],"/")[[1]]
	cur_subject<-cur_subject[length(cur_subject)]
	cur_subject<-gsub(".tsv","",cur_subject)
	features<-rbind(features,data.frame(cur_subject,
	                                    stationary_day=percent_stationary_weekday,
	                                    stationary_end=percent_stationary_weekend,
	                                    walking_day=percent_active_weekday,
	                                    walking_end=percent_active_weekend,
	                                    changes_day=num_transitions_weekday,
	                                    changes_end=num_transitions_weekend,
	 						     stringsAsFactors = FALSE))
}
save(features,file=paste("breakpoints",numpoints,startf,endf,sep="_"))