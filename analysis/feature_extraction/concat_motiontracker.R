library(data.table) 
#CONCATENATES FEATURE FILES FROM SCG PARALLEL EXECUTION
#pass the prefix for files to concatenate as an argument 
args<-commandArgs(trailingOnly= TRUE) 
path<-args[1]
prefix<-args[2] 
path="/home/annashch/myheartcounts/anna_code/feature_extraction/motiontrackerDF" 
prefix="motiontracker_"
files<-list.files(path=path,pattern=paste(prefix,"*",sep=""),full.names=T,recursive=FALSE) 
gotfirst_weekday=FALSE
gotfirst_weekend=FALSE 
for(i in 1:length(files))
{
print(files[i]) 
load(files[i]) 
if(grepl("weekday",files[i])==TRUE)
{
#weekday data 
if(gotfirst_weekday==FALSE)
{
full_weekday_activity_state<-weekday_activity_state 
full_weekday_arima<-weekday_arima 
full_weekday_fourier<-weekday_fourier 
full_weekday_paa<-weekday_paa 
full_weekday_svd<-weekday_svd
full_weekday_timeseries<-weekday_timeseries 
full_weekday_dwt<-weekday_dwt 
gotfirst_weekday=TRUE 
}
else
{
full_weekday_activity_state<-rbind(full_weekday_activity_state,weekday_activity_state) 
full_weekday_arima<-rbind(full_weekday_arima,weekday_arima) 
full_weekday_fourier<-rbind(full_weekday_fourier,weekday_fourier) 
full_weekday_paa<-rbind(full_weekday_paa,weekday_paa)
full_weekday_svd<-rbind(full_weekday_svd,weekday_svd) 
full_weekday_timeseries<-rbind(full_weekday_timeseries,weekday_timeseries) 
for(j in 1:length(full_weekday_dwt))
{
full_weekday_dwt[[j]]<-rbind(full_weekday_dwt[[j]],weekday_dwt[[j]])
}
}

}

else
{
#weekend data
if(gotfirst_weekend==FALSE)
{
full_weekend_activity_state<-weekend_activity_state
full_weekend_arima<-weekend_arima 
full_weekend_fourier<-weekend_fourier 
full_weekend_paa<-weekend_paa 
full_weekend_svd<-weekend_svd
full_weekend_timeseries<-weekend_timeseries 
full_weekend_dwt<-weekend_dwt 
gotfirst_weekend=TRUE 
}
else
{
full_weekend_activity_state<-rbind(full_weekend_activity_state,weekend_activity_state) 
full_weekend_arima<-rbind(full_weekend_arima,weekend_arima) 
full_weekend_fourier<-rbind(full_weekend_fourier,weekend_fourier) 
full_weekend_paa<-rbind(full_weekend_paa,weekend_paa)
full_weekend_svd<-rbind(full_weekend_svd,weekend_svd) 
full_weekend_timeseries<-rbind(full_weekend_timeseries,weekend_timeseries) 
for(j in 1:length(full_weekend_dwt))
{
full_weekend_dwt[[j]]<-rbind(full_weekend_dwt[[j]],weekend_dwt[[j]])
}
}
}
}

save(full_weekday_activity_state,full_weekday_arima,full_weekday_fourier,full_weekday_paa,full_weekday_svd,full_weekday_timeseries,full_weekday_dwt,full_weekend_activity_state,full_weekend_arima,full_weekend_fourier,full_weekend_paa,full_weekend_svd,full_weekend_timeseries,full_weekend_dwt,file="motion_tracker_concatenated")