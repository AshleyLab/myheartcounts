library(wavelets) 
library(data.table)

ss<-function(x)
{
  sum(x^2)
}

#magic numbers
changepoint_thresh<-10
n_levels<-10
min_valid_duration<-355 #subject must have 6 minutes +/- 5 seconds of data to be used in the analysis 
max_valid_duration<-365 
min_valid_rest_duration<-180
max_valid_rest_duration<-365 

#directories with acceleration data
accel_walk_dir<-'/home/anna/6minute_walk_small/acceleration_walk'
accel_rest_dir<-'/home/anna/6minute_walk_small/acceleration_rest'

#age, sex, other categorical information 
metadata<-'/home/anna/ashleylab_git/myhealthapp/Non_timeseries_data_07012014.tsv'

#Pedometer for QC 
pedometer_dir<-'/home/anna/6minute_walk/pedometer'
#############################################################################################
#CREATE A DATA FRAME FOR FEATURE STORAGE
features<-data.frame(cur_subject=character(),
                     walk=double(),
                     rest=double(),stringsAsFactors=FALSE)

#############################################################################################
#extract features for acceleration walk
files <- list.files(path=accel_walk_dir, pattern="*.tsv", full.names=T, recursive=FALSE)
for (i in 1:length(files)){
  x<-fread(files[i],header=T)
  #print(paste("iteration:",i))
  
  #CHECK FOR THE CHANGEPOINTS 
  delta<-diff(x$timestamp)
  changepoints<-which(delta %in% subset(delta,abs(delta)>changepoint_thresh))
  changepoints<-c(0,changepoints,length(x$timestamp))
  for (j in 1:(length(changepoints)-1))
  {cur_segment=x[changepoints[j]:changepoints[j+1],]
  #MAKE SURE THERE ARE 6 MINUTES OF DATA 
  duration<-cur_segment$timestamp[length(cur_segment$timestamp)] - cur_segment$timestamp[1]
  if ((duration > min_valid_duration) && (duration < max_valid_duration))
  {
    #USE THIS ITERATION OF THE TEST!
    
    #TAKE THE DWT TRANSFORM 
    dwt_x<-dwt(cur_segment$x,n.level=n_levels)
    dwt_y<-dwt(cur_segment$y,n.level=n_levels)
    dwt_z<-dwt(cur_segment$z,n.level=n_levels)
    
    #GET THE SUM OF SQUARES FOR THE DWT COEFFICIENTS
    x_coef=sapply(dwt_x@W,ss)
    y_coef=sapply(dwt_y@W,ss)
    z_coef=sapply(dwt_z@W,ss)
    #STORE THE COEFFICIENTS IN THE FEATURE MATRIX THAT WE ARE BUILDING
    cur_subject<-strsplit(files[i],"/")[[1]]
    cur_subject<-cur_subject[length(cur_subject)]
    cur_subject<-gsub(".tsv","",cur_subject)
    print(i)
    names(x_coef)=NULL 
    names(y_coef)=NULL 
    names(z_coef)=NULL 
    features<-rbind(features,data.frame(cur_subject,c(x_coef,y_coef,z_coef,rep(NA,30)),stringsAsFactors = FALSE))
    break 
  }
  }   
}


#REPEAT FOR THE ACCELERATION REST DATA 
files <- list.files(path=accel_rest_dir, pattern="*.tsv", full.names=T, recursive=FALSE)
for (i in 1:length(files)){
  x<-fread(files[i],header=T)
  #print(paste("iteration:",i))
  print(i) 
  #CHECK FOR THE CHANGEPOINTS 
  delta<-diff(x$timestamp)
  changepoints<-which(delta %in% subset(delta,abs(delta)>changepoint_thresh))
  changepoints<-c(0,changepoints,length(x$timestamp))
  for (j in 1:(length(changepoints)-1))
  {cur_segment=x[changepoints[j]:changepoints[j+1],]
  #MAKE SURE THERE ARE 6 MINUTES OF DATA 
  duration<-cur_segment$timestamp[length(cur_segment$timestamp)] - cur_segment$timestamp[1]
  if ((duration > min_valid_rest_duration) && (duration < max_valid_rest_duration))
  {
    #USE THIS ITERATION OF THE TEST!
    
    #TAKE THE DWT TRANSFORM 
    dwt_x<-dwt(cur_segment$x,n.level=n_levels)
    dwt_y<-dwt(cur_segment$y,n.level=n_levels)
    dwt_z<-dwt(cur_segment$z,n.level=n_levels)
    
    #GET THE SUM OF SQUARES FOR THE DWT COEFFICIENTS
    x_coef=sapply(dwt_x@W,ss)
    y_coef=sapply(dwt_y@W,ss)
    z_coef=sapply(dwt_z@W,ss)
    #CHECK TO SEE IF AN ENTRY FOR THE SUBJECT ALREADY EXISTS IN THE DATAFRAME
    cur_subject<-strsplit(files[i],"/")[[1]]
    cur_subject<-cur_subject[length(cur_subject)]
    cur_subject<-gsub(".tsv","",cur_subject)
    
    subject_index<-which(features$cur_subject %in% cur_subject)
    browser() 
    if(length(subject_index)==0)
    {#CREATE A NEW ENTRY
      features<-rbind(features,data.frame(cur_subject,c(rep(NA,30),c(x_coef,y_coef,z_coef)),stringsAsFactors = FALSE))}
    else{
      #INSERT FEATURE COEFFICIENTS INTO THE EXISTING ENTRY
      browser() 
      features[subject_index]$rx1=x_coef[1]
      features[subject_index]$rx2=x_coef[2] 
      features[subject_index]$rx3=x_coef[3]
    }
    break 
    
  }
  }
}
#cluster the feature data

#develop a classifier for age and sex
#train
#test

