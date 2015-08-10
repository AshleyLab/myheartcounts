library(wavelets) 
library(data.table)
source('extract_features.R')
source('extract_features_multiaxes.R')  
source('helpers.R') 
source('parameters.R') 

#For parallel execution on a cluster! These are start and end indices for subject files to parse 

args <- commandArgs(trailingOnly = TRUE)
startf<-args[1] 
endf<-args[2] 


#############################################################################################
#CREATE A DATA FRAME FOR FEATURE STORAGE
features<-data.frame(cur_subject=character(),
                     walk=double(),
                     rest=double(),stringsAsFactors=FALSE)

#############################################################################################
#extract features for acceleration walk
print("Analyzing motion acceleration data") 
files <- list.files(path=accel_walk_dir, pattern="*.tsv", full.names=T, recursive=FALSE)
if (length(args)==0)
{
#process all the files 
startf=1 
endf=length(files) 
}
if(endf > length(files))
{
endf=length(files) 
}
if(startf<= length(files))
{
gotfirst=FALSE 
for (i in startf:endf){
  data<-na.omit(fread(files[i],header=T))
  cur_subject<-strsplit(files[i],"/")[[1]]
  cur_subject<-cur_subject[length(cur_subject)]
  cur_subject<-gsub(".tsv","",cur_subject)
  print(cur_subject) 
  #CHECK FOR THE CHANGEPOINTS 
  delta<-diff(data$timestamp)
  changepoints<-which(delta %in% subset(delta,abs(delta)>changepoint_thresh))
  changepoints<-c(0,changepoints,length(data$timestamp))
  for (j in 1:(length(changepoints)-1))
  {cur_segment=data[changepoints[j]:changepoints[j+1],]

  #MAKE SURE THERE ARE 6 MINUTES OF DATA 
  duration<-cur_segment$timestamp[length(cur_segment$timestamp)] - cur_segment$timestamp[1]
  if ((duration > min_valid_duration) && (duration < max_valid_duration))
  {
    #USE THIS ITERATION OF THE TEST!
    #EXTRACT ALL THE FEATURES FOR X, Y, Z axes 

    l <- nrow(cur_segment) 
    outputvals<-get_fs(cur_segment$timestamp)
    fs<-outputvals[1] 
    duration<-outputvals[2] 
    axis_data<-subset(cur_segment,select=c("x","y","z"))
    #concatenate data frame for subjects 
    if(gotfirst==FALSE)
    {
    walk_result_arima<-arima_features_multi(axis_data,cur_subject)
    walk_result_timeseries<-ts_features_multi(axis_data,fs,duration,cur_subject)
    walk_result_fourier<-fourier_transform_features_multi(axis_data,fs,duration,cur_subject) 
    walk_result_dwt<-dwt_transform_features_multi(axis_data,cur_subject)
    walk_result_paa=piecewise_aggregate_multi(axis_data, duration, periodic=TRUE,cur_subject)
    walk_result_svd=svd_features_multi(axis_data,cur_subject)
    walk_result_paa_aggregate=piecewise_aggregate_resultant(cur_segment$x,cur_segment$y,cur_segment$z,duration, periodic=TRUE,cur_subject)   
    gotfirst=TRUE 
    }	  
    else
    {
    #use rbind to add a row for the new subject to the existing feature dataframes 
    walk_result_arima<-rbind(walk_result_arima,arima_features_multi(axis_data,cur_subject))    
    walk_result_timeseries<-rbind(walk_result_timeseries,ts_features_multi(axis_data,fs,duration,cur_subject))
    walk_result_fourier<-rbind(walk_result_fourier,fourier_transform_features_multi(axis_data,fs,duration,cur_subject)) 
    walk_result_paa<-rbind(walk_result_paa,piecewise_aggregate_multi(axis_data, duration, periodic=TRUE,cur_subject))
    walk_result_svd<-rbind(walk_result_svd,svd_features_multi(axis_data,cur_subject))
    walk_result_paa_aggregate<-rbind(walk_result_paa_aggregate,piecewise_aggregate_resultant(cur_segment$x,cur_segment$y,cur_segment$z,duration, periodic=TRUE,cur_subject)   )

    #this is a list of dataframes for each level 
    next_dwt_features<-dwt_transform_features_multi(axis_data,cur_subject)
    for (j in 1:length(walk_result_dwt))
    {
      walk_result_dwt[[j]]<-rbind(walk_result_dwt[[j]],next_dwt_features[[j]])      
    }
    }
    break 
    }
    } 
  }     
print("writing output binary acceleration walk file") 
save(walk_result_arima,walk_result_timeseries,walk_result_fourier,walk_result_paa,walk_result_svd,walk_result_paa_aggregate,walk_result_dwt,
	file=paste("6minwalk_walk",startf,endf,sep="_"))

}
print("Analyzing rest acceleration data") 
#REPEAT FOR THE ACCELERATION REST DATA 
files <- list.files(path=accel_rest_dir, pattern="*.tsv", full.names=T, recursive=FALSE)
if (length(args)==0)
{
#process all the files 
startf=1 
endf=length(files) 
}
if(endf >length(files))
{
endf=length(files) 
}
if(startf<=length(files))
{
gotfirst=FALSE 
for (i in startf:endf){
  data<-na.omit(fread(files[i],header=T))
  cur_subject<-strsplit(files[i],"/")[[1]]
  cur_subject<-cur_subject[length(cur_subject)]
  cur_subject<-gsub(".tsv","",cur_subject)
  print(cur_subject) 

  #CHECK FOR THE CHANGEPOINTS 
  delta<-diff(data$timestamp)
  changepoints<-which(delta %in% subset(delta,abs(delta)>changepoint_thresh))
  changepoints<-c(0,changepoints,length(data$timestamp))
  for (j in 1:(length(changepoints)-1))
  {cur_segment=data[changepoints[j]:changepoints[j+1],]

  #MAKE SURE THERE ARE 6 MINUTES OF DATA 
  duration<-cur_segment$timestamp[length(cur_segment$timestamp)] - cur_segment$timestamp[1] 
  if ((duration > min_valid_rest_duration) && (duration < max_valid_rest_duration))
  {
    #USE THIS ITERATION OF THE TEST!
    #EXTRACT ALL THE FEATURES FOR X, Y, Z axes 

    l <- nrow(cur_segment) 
    outputvals<-get_fs(cur_segment$timestamp)
    fs<-outputvals[1] 
    duration<-outputvals[2] 
    axis_data<-subset(cur_segment,select=c("x","y","z"))
    #concatenate data frame for subjects 
    if(gotfirst==FALSE)
    {
    rest_result_arima<-arima_features_multi(axis_data,cur_subject)
    rest_result_timeseries<-ts_features_multi(axis_data,fs,duration,cur_subject)
    rest_result_fourier<-fourier_transform_features_multi(axis_data,fs,duration,cur_subject) 
    rest_result_dwt<-dwt_transform_features_multi(axis_data,cur_subject)
    rest_result_paa=piecewise_aggregate_multi(axis_data, duration, periodic=TRUE,cur_subject)
    rest_result_svd=svd_features_multi(axis_data,cur_subject)
    rest_result_paa_aggregate=piecewise_aggregate_resultant(cur_segment$x,cur_segment$y,cur_segment$z,duration, periodic=TRUE,cur_subject)   
    gotfirst=TRUE 
    }	  
    else
    {
    #use rbind to add a row for the new subject to the existing feature dataframes 
    rest_result_arima<-rbind(rest_result_arima,arima_features_multi(axis_data,cur_subject))    
    rest_result_timeseries<-rbind(rest_result_timeseries,ts_features_multi(axis_data,fs,duration,cur_subject))
    rest_result_fourier<-rbind(rest_result_fourier,fourier_transform_features_multi(axis_data,fs,duration,cur_subject)) 
    rest_result_paa<-rbind(rest_result_paa,piecewise_aggregate_multi(axis_data, duration, periodic=TRUE,cur_subject))
    rest_result_svd<-rbind(rest_result_svd,svd_features_multi(axis_data,cur_subject))
    rest_result_paa_aggregate<-rbind(rest_result_paa_aggregate,piecewise_aggregate_resultant(cur_segment$x,cur_segment$y,cur_segment$z,duration, periodic=TRUE,cur_subject)   )

    #this is a list of dataframes for each level 
    next_dwt_features<-dwt_transform_features_multi(axis_data,cur_subject)
    for (j in 1:length(rest_result_dwt))
    {
      rest_result_dwt[[j]]<-rbind(rest_result_dwt[[j]],next_dwt_features[[j]])      
    }
    }
    break 
    }
    } 
  }     
print("writing output binary rest file") 
save(rest_result_arima,rest_result_timeseries,rest_result_fourier,rest_result_paa,rest_result_svd,rest_result_paa_aggregate,rest_result_dwt,
     file=paste("6minwalk_rest",startf,endf,sep="_"))
}