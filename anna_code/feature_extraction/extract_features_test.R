rm(list=ls())
source("extract_features.R") 
walk_dir<-"/home/anna/6minute_walk_small/acceleration_walk" 
rest_dir<-"/home/anna/6minute_walk_small/acceleration_rest"

files <- list.files(path=walk_dir, pattern="*.tsv", full.names=T, recursive=FALSE)

for (i in 1:length(files)){
  data<-na.omit(fread(files[i],header=T))
  x<-data$x[1:min(36000,nrow(data))]
  y<-data$y[1:min(36000,nrow(data))]
  z<-data$z[1:min(36000,nrow(data))]
  cur_subject<-strsplit(files[i],"/")[[1]]
  cur_subject<-cur_subject[length(cur_subject)]
  cur_subject<-gsub(".tsv","",cur_subject)
  print(cur_subject)
  
  l <- length(x)
  outputvals<-get_fs(data$timestamp[1:min(36000,nrow(data))])
  fs<-outputvals[1] 
  duration<-outputvals[2] 
  
  #Test all the feature extraction models and result concatenation 
  if(i==1) #create the data frames from scratch 
  {
    result_arima<-arima_features(x,cur_subject)
    result_timeseries<-ts_features(x,fs,duration,cur_subject)
    result_fourier<-fourier_transform_features(data$x,fs,duration,cur_subject) 
    result_dwt<-dwt_transform_features(data$x,cur_subject)
    result_paa=piecewise_aggregate(x, duration, periodic=TRUE,cur_subject)
    result_paa_aggregate=piecewise_aggregate_resultant(x,y,z,duration, periodic=TRUE,cur_subject)
    result_svd=svd_features(x,cur_subject)
  } 
  else
  {#use rbind to add a row for the new subject to the existing feature dataframes 
    result_arima<-rbind(result_arima,arima_features(x,cur_subject))
    result_timeseries<-rbind(result_timeseries,ts_features(x,fs,duration,cur_subject))
    result_fourier<-rbind(result_fourier,fourier_transform_features(data$x,fs,duration,cur_subject)) 
    result_paa<-rbind(result_paa,piecewise_aggregate(x, duration, periodic=TRUE,cur_subject))
    result_paa_aggregate<-rbind(result_paa_aggregate,piecewise_aggregate_resultant(x,y,z,duration, periodic=TRUE,cur_subject))
    result_svd<-rbind(result_svd,svd_features(x,cur_subject))
    #this is a list of dataframes for each level 
    next_dwt_features<-dwt_transform_features(data$x,cur_subject)
    for (j in 1:length(result_dwt))
    {
      result_dwt[[j]]<-rbind(result_dwt[[j]],next_dwt_features[[j]])
    }
  }
}