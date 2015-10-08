#merges separate dataframes for the motion tracker data 
rm(list=ls())
library(data.table)
load("motion_tracker_concatenated")
#empirically, pca on DWT showed that using the level 7 transform gives the best data separation by components 1,2,3 
full_weekday_dwt<-full_weekday_dwt[[7]]
full_weekend_dwt<-full_weekend_dwt[[7]]
browser() 
#rownames(full_weekday_timeseries)=rownames(full_weekday_fourier)
#rownames(full_weekend_timeseries)=rownames(full_weekend_fourier)
#get the set of subjects that havet data in each of the data frames 
subjects1<-rownames(full_weekday_activity_state)
subjects2<-rownames(full_weekday_arima)
subjects3<-rownames(full_weekday_dwt)
subjects4<-rownames(full_weekday_fourier)
subjects5<-rownames(full_weekday_paa)
subjects6<-rownames(full_weekday_svd)
subjects7<-rownames(full_weekday_timeseries)

subjects8<-rownames(full_weekend_activity_state)
subjects9<-rownames(full_weekend_arima)
subjects10<-rownames(full_weekend_dwt)
subjects11<-rownames(full_weekend_fourier)
subjects12<-rownames(full_weekend_paa)
subjects13<-rownames(full_weekend_svd)
subjects14<-rownames(full_weekend_timeseries)

common=subjects1
common=intersect(common,subjects2)
common=intersect(common,subjects3)
common=intersect(common,subjects4)
common=intersect(common,subjects5)
common=intersect(common,subjects6)
common=intersect(common,subjects7)
common=intersect(common,subjects8)
common=intersect(common,subjects9)
common=intersect(common,subjects10)
common=intersect(common,subjects11)
common=intersect(common,subjects12)
common=intersect(common,subjects13)
common=intersect(common,subjects14)

full_weekday_activity_state<-full_weekday_activity_state[common,]
full_weekday_arima<-full_weekday_arima[common,]
full_weekday_dwt<-full_weekday_dwt[common,]
full_weekday_fourier<-full_weekday_fourier[common,]
full_weekday_paa<-full_weekday_paa[common,]
full_weekday_svd<-full_weekday_svd[common,]
full_weekday_timeseries<-full_weekday_timeseries[common,]
full_weekend_activity_state<-full_weekend_activity_state[common,]
full_weekend_arima<-full_weekend_arima[common,]
full_weekend_dwt<-full_weekend_dwt[common,]
full_weekend_fourier<-full_weekend_fourier[common,]
full_weekend_paa<-full_weekend_paa[common,]
full_weekend_svd<-full_weekend_svd[common,]
full_weekend_timeseries<-full_weekend_timeseries[common,]
#preface the names of each dataframe with weekday or weekend 
weekday_df=cbind(full_weekday_activity_state,full_weekday_arima,full_weekday_dwt,full_weekday_fourier,full_weekday_paa,full_weekday_svd,full_weekday_timeseries)
weekend_df=cbind(full_weekend_activity_state,full_weekend_arima,full_weekend_dwt,full_weekend_fourier,full_weekend_paa,full_weekend_svd,full_weekend_timeseries)
names<-names(weekday_df)
weekday_names<-c() 
for(i in 1:length(names))
{
 
  weekday_names<-c(weekday_names,paste(names[i],"_weekday",sep=""))
}
names(weekday_df)<-weekday_names 


names<-names(weekend_df)
weekend_names<-c() 
for(i in 1:length(names))
{
  
  weekend_names<-c(weekend_names,paste(names[i],"_weekend",sep=""))
}
names(weekend_df)<-weekend_names 
#use cbind to paste dataframes together 
merged_df<-cbind(weekend_df,weekday_df)
save(merged_df,file='motion_tracker_merged_df')