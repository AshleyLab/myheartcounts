library(wavelets) 
library(data.table)

ss<-function(x)
{
  sum(x^2)
}

#magic numbers
n_levels<-10
min_entries<-1000


#directories with acceleration data
#weekday_dir<-'/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/weekday'
weekend_dir<-'/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/weekend'
weekday_dir<-'/home/annashch/r_scripts'



#############################################################################################
#CREATE A DATA FRAME FOR FEATURE STORAGE
features<-data.frame(cur_subject=character(),
		     automotive_day=double,
		     automative_end=double,
		     cycling_day=double, 
		     cycling_end=double,
		     running_day=double,
		     running_end=double,
		     stationary_day=double,
		     stationary_end=double,
		     unknown_day=double, 
		     unknown_end=double, 
		     walking_day=double,
		     walking_end=double, 
		     num_datapoints_day=double,
		     num_datapoints_end=double,
		     mean_interval_day=double,
		     mean_interval_end=double
		     ,stringsAsFactors=FALSE)

#############################################################################################
#extract features for acceleration walk
files <- list.files(path=weekday_dir, pattern="*.tsv", full.names=T, recursive=FALSE)
for (i in 1:length(files)){
    print(i) 
    success<-FALSE
    try({
    signal_weekday<-as.data.frame(read.table(files[i],header=F,stringsAsFactors=FALSE,sep="\t"))
    #weekend_file_name<-gsub("weekday","weekend",files[i])
    weekend_file_name<-gsub("/home/annashch/r_scripts","/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/weekend",files[i])
    signal_weekend<-as.data.frame(read.table(weekend_file_name,header=F,stringsAsFactors=FALSE,sep="\t"))

    #COMPUTE THE FEATURES THAT ARE NOT PART OF THE DWT 
    time_day<-strptime(signal_weekday$V1,"%Y-%m-%dT%H:%M:%S")
    time_end<-strptime(signal_weekend$V1,"%Y-%m-%dT%H:%M:%S")
    timediff_end<-as.numeric(diff(time_end))
    timediff_day<-as.numeric(diff(time_day)) 
    num_entries_day=length(time_day) 
    num_entries_end=length(time_end)  
    mean_timediff_end=mean(timediff_end) 
    mean_timediff_day=mean(timediff_day) 

    #GET THE PROPORTION OF EACH ACTIVITY 
    activities_day<-factor(signal_weekday$V2) 
    activities_end<-factor(signal_weekend$V2) 
    automotive_day<-length(which(activities_day=="automotive"))/num_entries_day
    automotive_end<-length(which(activities_end=="automotive"))/num_entries_end
    cycling_day<-length(which(activities_day=="cycling"))/num_entries_day
    cycling_end<-length(which(activities_end=="cycling"))/num_entries_end 
    running_day<-length(which(activities_day=="running"))/num_entries_day
    running_end<-length(which(activities_end=="running"))/num_entries_end
    stationary_day<-length(which(activities_day=="stationary"))/num_entries_day
    stationary_end<-length(which(activities_end=="stationary"))/num_entries_end  
    unknown_day<-length(which(activities_day=="unknown"))/num_entries_day  
    unknown_end<-length(which(activities_end=="unknown"))/num_entries_end  
    walking_day<-length(which(activities_day=="walking"))/num_entries_day 
    walking_end<-length(which(activities_end=="walking"))/num_entries_end 

    #COMPUTE THE LEVELS OF THE DWT 
	cur_subject<-strsplit(files[i],"/")[[1]]
	cur_subject<-cur_subject[length(cur_subject)]
	cur_subject<-gsub(".tsv","",cur_subject)
	features<-rbind(features,data.frame(cur_subject,

						    automotive_day=automotive_day,
						    automative_end=automotive_end,
						    cycling_day=cycling_day, 
						    cycling_end=cycling_end,
						    running_day=running_day,
						    running_end=running_end,
					            stationary_day=stationary_day,
						     stationary_end=stationary_end,
						     unknown_day=unknown_day, 
						     unknown_end=unknown_end, 
						     walking_day=walking_day,
						     walking_end=walking_end, 
						     num_datapoints_day=num_entries_day,
						     num_datapoints_end=num_entries_end,
						     mean_interval_day=mean_timediff_day,
						     mean_interval_end=mean_timediff_end,
 						     stringsAsFactors = FALSE))

	success<-TRUE 
	})
	if(success==FALSE)
	{
	print(files[i]) 
	}
    }

rownames(features)=features$cur_subject
#feat_subset=subset(features[,2:21])
#features=feat_subset 
write.table(features,file="motiontracker_data_basics_pass2.txt")
