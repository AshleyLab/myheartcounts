library(wavelets) 
library(data.table)
source('extract_features.R')
source('extract_features_multiaxes.R')  
source('helpers.R') 
source('parameters.R') 

args <- commandArgs(trailingOnly = TRUE)
startf<-args[1] 
endf<-args[2] 
#############################################################################################

#extract features for acceleration walk
gotfirst=FALSE
files <- list.files(path=weekday_dir, pattern="*.tsv", full.names=T, recursive=FALSE)
for (i in startf:endf){
    success<-FALSE
    #print(i) 
    #STORE THE COEFFICIENTS IN THE FEATURE MATRIX THAT WE ARE BUILDING
    cur_subject<-strsplit(files[i],"/")[[1]]
    cur_subject<-cur_subject[length(cur_subject)]
    cur_subject<-gsub(".tsv","",cur_subject)
    print(cur_subject) 
    try(
    {
    signal_weekday<-as.data.frame(read.table(files[i],header=F,stringsAsFactors=FALSE,sep="\t"))
    weekend_file_name<-gsub("weekday","weekend",files[i])
    signal_weekend<-as.data.frame(read.table(weekend_file_name,header=F,stringsAsFactors=FALSE,sep="\t"))
    timestamp_weekday<-signal_weekday$V1 
    timestamp_weekend<-signal_weekend$V1 
    act_weekday<-signal_weekday$V2 
    act_weekend<-signal_weekend$V2 
    signal_weekday<-as.numeric(signal_weekday$V3) 
    signal_weekend<-as.numeric(signal_weekend$V3) 
  

    l_weekday <- length(signal_weekday) 
    outputvals_weekday<-get_fs(timestamp_weekday)
    fs_weekday<-outputvals_weekday[1] 
    duration_weekday<-outputvals_weekday[2] 
    

    l_weekend <- length(signal_weekend) 
    outputvals_weekend<-get_fs(timestamp_weekend)
    fs_weekend<-outputvals_weekend[1] 
    duration_weekend<-outputvals_weekend[2] 


    if(gotfirst==FALSE)
    {
    #get the weekday features 
    weekday_arima<-arima_features(signal_weekday,cur_subject)
    weekday_timeseries<-ts_features(signal_weekday,fs_weekday,duration_weekday,cur_subject) 
    weekday_fourier<-fourier_transform_features(signal_weekday,fs_weekday,duration_weekday,cur_subject)
    weekday_dwt<-dwt_transform_features(signal_weekday,cur_subject)
    weekday_paa=piecewise_aggregate(signal_weekday, duration_weekday, periodic=FALSE,cur_subject)
    weekday_svd=svd_features(signal_weekday,cur_subject)
    weekday_activity_state=activity_state_features(timestamp_weekday,act_weekday,cur_subject)

    #get the weekend features 
    weekend_arima<-arima_features(signal_weekend,cur_subject)
    weekend_timeseries<-ts_features(signal_weekend,fs_weekend,duration_weekend,cur_subject) 
    weekend_fourier<-fourier_transform_features(signal_weekend,fs_weekend,duration_weekend,cur_subject)
    weekend_dwt<-dwt_transform_features(signal_weekend,cur_subject)
    weekend_paa=piecewise_aggregate(signal_weekend, duration_weekend, periodic=FALSE,cur_subject)
    weekend_svd=svd_features(signal_weekend,cur_subject)
    weekend_activity_state=activity_state_features(timestamp_weekend,act_weekend,cur_subject)	
    gotfirst=TRUE
    }
    else
    {
    #get the weekday features 
    print("weekday") 
    weekday_arima<-rbind(weekday_arima,arima_features(signal_weekday,cur_subject))
    print("arima") 

    weekday_timeseries<-rbind(weekday_timeseries,ts_features(signal_weekday,fs_weekday,duration_weekday,cur_subject))
    print("ts") 
    weekday_fourier<-rbind(weekday_fourier,fourier_transform_features(signal_weekday,fs_weekday,duration_weekday,cur_subject)) 
    print("fourier")
    weekday_dwt<-rbind(weekday_dwt,dwt_transform_features(signal_weekday,cur_subject)) 
    print("dwt") 
    weekday_paa<-rbind(weekday_paa,piecewise_aggregate(signal_weekday,duration_weekday,periodic=FALSE,cur_subject))
    print("paa") 
    weekday_svd<-rbind(weekday_svd,svd_features(signal_weekday,cur_subject)) 
    print("svd") 
    weekday_activity_state<-rbind(weekday_activity_state,activity_state_features(timestamp_weekday,act_weekday,cur_subject))
    print("activity state") 

    #get the weekend features 
    print("weekend")
    weekend_arima<-rbind(weekend_arima,arima_features(signal_weekend,cur_subject))
    weekend_timeseries<-rbind(weekend_timeseries,ts_features(signal_weekend,fs_weekend,duration_weekend,cur_subject))
    weekend_fourier<-rbind(weekend_fourier,fourier_transform_features(signal_weekend,fs_weekend,duration_weekend,cur_subject))
    weekend_dwt<-rbind(weekend_dwt,dwt_transform_features(signal_weekend,cur_subject))
    weekend_paa<-rbind(weekend_paa,piecewise_aggregate(signal_weekend,duration_weekend,periodic=FALSE,cur_subject))
    weekend_svd<-rbind(weekend_svd,svd_features(signal_weekend,cur_subject))
    weekend_activity_state<-rbind(weekend_activity_state,activity_state_features(timestamp_weekend,act_weekend,cur_subject))
    }
  })
}
print("writing output binary weekday  file") 
save(weekday_arima,weekday_timeseries,weekday_fourier,weekday_dwt,weekday_paa,weekday_svd,weekday_activity_state,file=paste("motiontracker_weekday",startf,endf,sep="_"))
print("writing out binary weekend file") 
save(weekend_arima,weekend_timeseries,weekend_fourier,weekend_dwt,weekend_paa,weekend_svd,weekend_activity_state,file=paste("motiontracker_weekend",startf,endf,sep="_"))