#wrappers for running feature extraction on multiple data axes (i.e. x,y,z data for accelerometers)
source('extract_features.R')
source('helpers.R')
source('parameters.R')

activity_state_features_multi<-function(timestamps_day,timestamps_end,activity_day,activity_end,subject)
{
weekday_result<-activity_state_features(timestamps_day,activity_day,subject,"_weekday") 
weekend_result<-activity_state_features(timestamps_end,activity_end,subject,"_weekend")
merged_df<-merge(weekday_result,weekend_result)
return(merged_df) 
}


arima_features_multi<-function(data,subject)
{
  for(i in names(data))
  {
    cur_name<-i 
    cur_col<-data[[cur_name]]
    cur_result<-arima_features(cur_col,subject)
    #update names to prefix with "cur_name" 
    cur_names<-sapply(names(cur_result),FUN=function(x) paste(x,i,sep='_'),simplify="vector",USE.NAMES = FALSE)
    names(cur_result)<-cur_names 
    if (exists("merged_df")==FALSE)
    {
      merged_df<-cur_result 
    }
    else
    {
      merged_df<-merge(merged_df,cur_result)
      rownames(merged_df)<-rownames(cur_result)
    }
  }
  return(merged_df)
}

ts_features_multi<-function(data,fs,duration,subject)
{
  for(i in names(data))
  {
    cur_name<-i 
    cur_col<-data[[cur_name]]
    cur_result<-ts_features(cur_col,fs,duration,subject)
    #update names to prefix with "cur_name" 
    cur_names<-sapply(names(cur_result),FUN=function(x) paste(x,i,sep='_'),simplify="vector",USE.NAMES = FALSE)
    names(cur_result)<-cur_names 
    if (exists("merged_df")==FALSE)
    {
      merged_df<-cur_result 
    }
    else
    {
      merged_df<-merge(merged_df,cur_result)
      rownames(merged_df)<-rownames(cur_result)
    }
  }
  return(merged_df)
}


ts_features_multi<-function(data,fs,duration,subject)
{
  for(i in names(data))
  {
    cur_name<-i 
    cur_col<-data[[cur_name]]
    cur_result<-ts_features(cur_col,fs,duration,subject)
    #update names to prefix with "cur_name" 
    cur_names<-sapply(names(cur_result),FUN=function(x) paste(x,i,sep='_'),simplify="vector",USE.NAMES = FALSE)
    names(cur_result)<-cur_names 
    if (exists("merged_df")==FALSE)
    {
      merged_df<-cur_result 
    }
    else
    {
      merged_df<-merge(merged_df,cur_result)
      rownames(merged_df)<-rownames(cur_result)
    }
  }
  return(merged_df)
}


dwt_transform_features_multi <- function(data,subject)
{ 
  for(i in names(data))
  {
    cur_name<-i 
    cur_col<-data[[cur_name]]
    cur_result<-dwt_transform_features(cur_col,subject)
    for(j in 1:length(cur_result))
    {
    #update names to prefix with "cur_name" 
    cur_names<-sapply(names(cur_result[[j]]),FUN=function(x) paste(x,i,sep='_'),simplify="vector",USE.NAMES = FALSE)
    names(cur_result[[j]])<-cur_names 
    }
    if (exists("merged_df")==FALSE)
    {
      merged_df<-cur_result 
    }
    else
    {
      for(j in 1:length(cur_result))
      {
      merged_df[[j]]<-merge(merged_df[[j]],cur_result[[j]])
      rownames(merged_df[[j]])<-rownames(cur_result[[j]])
    }
    }
  }
  return(merged_df)
  }


fourier_transform_features_multi<-function(data, fs, duration,subject)
{
  for(i in names(data))
  {
    cur_name<-i 
    cur_col<-data[[cur_name]]
    cur_result<-fourier_transform_features(cur_col,fs,duration,subject)
    #update names to prefix with "cur_name" 
    cur_names<-sapply(names(cur_result),FUN=function(x) paste(x,i,sep='_'),simplify="vector",USE.NAMES = FALSE)
    names(cur_result)<-cur_names 
    if (exists("merged_df")==FALSE)
    {
      merged_df<-cur_result 
    }
    else
    {
      merged_df<-merge(merged_df,cur_result)
      rownames(merged_df)<-rownames(cur_result)
    }
  }
  return(merged_df)
}

piecewise_aggregate_multi<-function(data, duration, periodic,subject)
{
  for(i in names(data))
  {
    cur_name<-i 
    cur_col<-data[[cur_name]]
    cur_result<-piecewise_aggregate(cur_col,duration,periodic,subject)
    #update names to prefix with "cur_name" 
    cur_names<-sapply(names(cur_result),FUN=function(x) paste(x,i,sep='_'),simplify="vector",USE.NAMES = FALSE)
    names(cur_result)<-cur_names 
    if (exists("merged_df")==FALSE)
    {
      merged_df<-cur_result 
    }
    else
    {
      merged_df<-merge(merged_df,cur_result)
      rownames(merged_df)<-rownames(cur_result)
    }
  }
  return(merged_df)
}
  

svd_features_multi<-function(data, subject)
{
  for(i in names(data))
  {
    cur_name<-i 
    cur_col<-data[[cur_name]]
    cur_result<-svd_features(cur_col,subject)
    #update names to prefix with "cur_name" 
    cur_names<-sapply(names(cur_result),FUN=function(x) paste(x,i,sep='_'),simplify="vector",USE.NAMES = FALSE)
    names(cur_result)<-cur_names 
    if (exists("merged_df")==FALSE)
    {
      merged_df<-cur_result 
    }
    else
    {
      merged_df<-merge(merged_df,cur_result)
      rownames(merged_df)<-rownames(cur_result)
    }
  }
  return(merged_df)
}
  
  

