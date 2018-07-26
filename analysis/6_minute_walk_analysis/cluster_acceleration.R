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
accel_walk_dir<-'/home/anna/6minute_walk/acceleration_walk'
accel_rest_dir<-'/home/anna/6minute_walk/acceleration_rest'

#age, sex, other categorical information 
metadata_file<-'/home/anna/ashleylab_git/myhealthapp/Non_timeseries_data_07012014.tsv'
meta=data.table(fread(metadata_file),row.names=1)

#Pedometer for QC 
pedometer_dir<-'/home/anna/6minute_walk/pedometer'
#############################################################################################
#CREATE A DATA FRAME FOR FEATURE STORAGE
features<-data.frame(cur_subject=character(),
                     wx1=double,
                     wx2=double,
                     wx3=double,
                     wx4=double,
                     wx5=double,
                     wx6=double,
                     wx7=double,
                     wx8=double,
                     wx9=double,
                     wx10=double,
                     wy1=double,
                     wy2=double,
                     wy3=double,
                     wy4=double,
                     wy5=double,
                     wy6=double,
                     wy7=double,
                     wy8=double,
                     wy9=double,
                     wy10=double,
                     wz1=double,
                     wz2=double,
                     wz3=double,
                     wz4=double,
                     wz5=double,
                     wz6=double,
                     wz7=double,
                     wz8=double,
                     wz9=double,
                     wz10=double,
                     rx1=double,
                     rx2=double,
                     rx3=double,
                     rx4=double,
                     rx5=double,
                     rx6=double,
                     rx7=double,
                     rx8=double,
                     rx9=double,
                     rx10=double,
                     ry1=double,
                     ry2=double,
                     ry3=double,
                     ry4=double,
                     ry5=double,
                     ry6=double,
                     ry7=double,
                     ry8=double,
                     ry9=double,
                     ry10=double,
                     rz1=double,
                     rz2=double,
                     rz3=double,
                     rz4=double,
                     rz5=double,
                     rz6=double,
                     rz7=double,
                     rz8=double,
                     rz9=double,
                     rz10=double,stringsAsFactors=FALSE)

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
		browser() 
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
		features<-rbind(features,data.frame(cur_subject,
		                                    wx1=x_coef[1],
		                                    wx2=x_coef[2],
		                                    wx3=x_coef[3],
		                                    wx4=x_coef[4],
		                                    wx5=x_coef[5],
		                                    wx6=x_coef[6],
		                                    wx7=x_coef[7],
		                                    wx8=x_coef[8],
		                                    wx9=x_coef[9],
		                                    wx10=x_coef[10],
		                                    wy1=y_coef[1],
		                                    wy2=y_coef[2],
		                                    wy3=y_coef[3],
		                                    wy4=y_coef[4],
		                                    wy5=y_coef[5],
		                                    wy6=y_coef[6],
		                                    wy7=y_coef[7],
		                                    wy8=y_coef[8],
		                                    wy9=y_coef[9],
		                                    wy10=y_coef[10],
		                                    wz1=z_coef[1],
		                                    wz2=z_coef[2],
		                                    wz3=z_coef[3],
		                                    wz4=z_coef[4],
		                                    wz5=z_coef[5],
		                                    wz6=z_coef[6],
		                                    wz7=z_coef[7],
		                                    wz8=z_coef[8],
		                                    wz9=z_coef[9],
		                                    wz10=z_coef[10],
		                                    rx1=NA,
		                                    rx2=NA,
		                                    rx3=NA,
		                                    rx4=NA,
		                                    rx5=NA,
		                                    rx6=NA,
		                                    rx7=NA,
		                                    rx8=NA,
		                                    rx9=NA,
		                                    rx10=NA,
		                                    ry1=NA,
		                                    ry2=NA,
		                                    ry3=NA,
		                                    ry4=NA,
		                                    ry5=NA,
		                                    ry6=NA,
		                                    ry7=NA,
		                                    ry8=NA,
		                                    ry9=NA,
		                                    ry10=NA,
		                                    rz1=NA,
		                                    rz2=NA,
		                                    rz3=NA,
                                        rz4=NA,
		                                    rz5=NA,
		                                    rz6=NA,
		                                    rz7=NA,		                                  
		                                    rz8=NA,
		                                    rz9=NA,
		                                    rz10=NA,stringsAsFactors = FALSE))
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

		names(x_coef)=NULL 
		names(y_coef)=NULL 
		names(z_coef)=NULL 
				
		subject_index<-which(features$cur_subject %in% cur_subject)
		if(length(subject_index)==0)
		{#CREATE A NEW ENTRY
		  features<-rbind(features,data.frame(cur_subject,		                                      
		                                      wx1=NA,
		                                      wx2=NA,
		                                      wx3=NA,
		                                      wx4=NA,
		                                      wx5=NA,
		                                      wx6=NA,
		                                      wx7=NA,
		                                      wx8=NA,
		                                      wx9=NA,
		                                      wx10=NA,
		                                      wy1=NA,
		                                      wy2=NA,
		                                      wy3=NA,
		                                      wy4=NA,
		                                      wy5=NA,
		                                      wy6=NA,
		                                      wy7=NA,
		                                      wy8=NA,
		                                      wy9=NA,
		                                      wy10=NA,
		                                      wz1=NA,
		                                      wz2=NA,
		                                      wz3=NA,
		                                      wz4=NA,
		                                      wz5=NA,
		                                      wz6=NA,
		                                      wz7=NA,		                                  
		                                      wz8=NA,
		                                      wz9=NA,
		                                      wz10=NA,
		                                      rx1=x_coef[1],
		                                      rx2=x_coef[2],
		                                      rx3=x_coef[3],
		                                      rx4=x_coef[4],
		                                      rx5=x_coef[5],
		                                      rx6=x_coef[6],
		                                      rx7=x_coef[7],
		                                      rx8=x_coef[8],
		                                      rx9=x_coef[9],
		                                      rx10=x_coef[10],
		                                      ry1=y_coef[1],
		                                      ry2=y_coef[2],
		                                      ry3=y_coef[3],
		                                      ry4=y_coef[4],
		                                      ry5=y_coef[5],
		                                      ry6=y_coef[6],
		                                      ry7=y_coef[7],
		                                      ry8=y_coef[8],
		                                      ry9=y_coef[9],
		                                      ry10=y_coef[10],
		                                      rz1=z_coef[1],
		                                      rz2=z_coef[2],
		                                      rz3=z_coef[3],
		                                      rz4=z_coef[4],
		                                      rz5=z_coef[5],
		                                      rz6=z_coef[6],
		                                      rz7=z_coef[7],
		                                      rz8=z_coef[8],
		                                      rz9=z_coef[9],
		                                      rz10=z_coef[10],stringsAsFactors = FALSE))}
		else{
		#INSERT FEATURE COEFFICIENTS INTO THE EXISTING ENTRY
		names(x_coef)=NULL 
		names(y_coef)=NULL 
		names(z_coef)=NULL 
		features[subject_index,]$rx1=x_coef[1]
		features[subject_index,]$rx2=x_coef[2] 
		features[subject_index,]$rx3=x_coef[3]
		features[subject_index,]$rx4=x_coef[4]
		features[subject_index,]$rx5=x_coef[5] 
		features[subject_index,]$rx6=x_coef[6]
		features[subject_index,]$rx7=x_coef[7]
		features[subject_index,]$rx8=x_coef[8] 
		features[subject_index,]$rx9=x_coef[9]
		features[subject_index,]$rx10=x_coef[10]
		features[subject_index,]$ry1=x_coef[1]
		features[subject_index,]$ry2=x_coef[2] 
		features[subject_index,]$ry3=x_coef[3]
		features[subject_index,]$ry4=x_coef[4]
		features[subject_index,]$ry5=x_coef[5] 
		features[subject_index,]$ry6=x_coef[6]
		features[subject_index,]$ry7=x_coef[7]
		features[subject_index,]$ry8=x_coef[8] 
		features[subject_index,]$ry9=x_coef[9]
		features[subject_index,]$ry10=x_coef[10]
		features[subject_index,]$rz1=x_coef[1]
		features[subject_index,]$rz2=x_coef[2] 
		features[subject_index,]$rz3=x_coef[3]
		features[subject_index,]$rz4=x_coef[4]
		features[subject_index,]$rz5=x_coef[5] 
		features[subject_index,]$rz6=x_coef[6]
		features[subject_index,]$rz7=x_coef[7]
		features[subject_index,]$rz8=x_coef[8] 
		features[subject_index,]$rz9=x_coef[9]
		features[subject_index,]$rz10=x_coef[10]
		}
		break 
		}
    }
}
rownames(features)=features$cur_subject
feat_subset=subset(features[,2:61])
features=feat_subset 
write.table(features,file="acceleration_data.txt")
#km=kmeans(na.omit(features),2)
#hc<-hclust(dist(features),method="complete")
#png('clusters_small.png')
#plot(hc)
#dev.off() 
#cluster the feature data

#develop a classifier for age and sex
#train
#test

