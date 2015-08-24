#merges separate dataframes for the motion tracker data 
rm(list=ls())
library(data.table)
load("6minwalk_concatenated")
#empirically, pca on DWT showed that using the level 8 transform gives the best data separation by components 1,2,3 
full_rest_result_dwt<-full_rest_result_dwt[[7]]
full_walk_result_dwt<-full_walk_result_dwt[[7]]
rownames(full_rest_result_timeseries)=rownames(full_rest_result_fourier)
rownames(full_walk_result_timeseries)=rownames(full_walk_result_fourier)
#get the set of subjects that havet data in each of the data frames 
subjects1<-rownames(full_rest_result_paa_aggregate)
subjects2<-rownames(full_rest_result_arima)
subjects3<-rownames(full_rest_result_dwt)
subjects4<-rownames(full_rest_result_fourier)
subjects5<-rownames(full_rest_result_paa)
subjects6<-rownames(full_rest_result_svd)
subjects7<-rownames(full_rest_result_timeseries)

subjects8<-rownames(full_walk_result_paa_aggregate)
subjects9<-rownames(full_walk_result_arima)
subjects10<-rownames(full_walk_result_dwt)
subjects11<-rownames(full_walk_result_fourier)
subjects12<-rownames(full_walk_result_paa)
subjects13<-rownames(full_walk_result_svd)
subjects14<-rownames(full_walk_result_timeseries)

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

full_rest_result_paa_aggregate<-full_rest_result_paa_aggregate[common,]
full_rest_result_arima<-full_rest_result_arima[common,]
full_rest_result_dwt<-full_rest_result_dwt[common,]
full_rest_result_fourier<-full_rest_result_fourier[common,]
full_rest_result_paa<-full_rest_result_paa[common,]
full_rest_result_svd<-full_rest_result_svd[common,]
full_rest_result_timeseries<-full_rest_result_timeseries[common,]
full_walk_result_paa_aggregate<-full_walk_result_paa_aggregate[common,]
full_walk_result_arima<-full_walk_result_arima[common,]
full_walk_result_dwt<-full_walk_result_dwt[common,]
full_walk_result_fourier<-full_walk_result_fourier[common,]
full_walk_result_paa<-full_walk_result_paa[common,]
full_walk_result_svd<-full_walk_result_svd[common,]
full_walk_result_timeseries<-full_walk_result_timeseries[common,]
#preface the names of each dataframe with rest or walk 
rest_df=cbind(full_rest_result_paa_aggregate,full_rest_result_arima,full_rest_result_dwt,full_rest_result_fourier,full_rest_result_paa,full_rest_result_svd,full_rest_result_timeseries)
walk_df=cbind(full_walk_result_paa_aggregate,full_walk_result_arima,full_walk_result_dwt,full_walk_result_fourier,full_walk_result_paa,full_walk_result_svd,full_walk_result_timeseries)
names<-names(rest_df)
rest_names<-c() 
for(i in 1:length(names))
{
 
  rest_names<-c(rest_names,paste(names[i],"_rest",sep=""))
}
names(rest_df)<-rest_names 


names<-names(walk_df)
walk_names<-c() 
for(i in 1:length(names))
{
  
  walk_names<-c(walk_names,paste(names[i],"_walk",sep=""))
}
names(walk_df)<-walk_names 
#use cbind to paste dataframes together 
merged_df<-cbind(walk_df,rest_df)
save(merged_df,file='6minwalk_merged_df')