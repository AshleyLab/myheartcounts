library(data.table) 
#Concatenates feature files from scg parallel execution 
#pass the prefix for files to concatenate as an argument 
args<-commandArgs(trailingOnly= TRUE) 
path<-args[1]
prefix<-args[2] 
path="/home/annashch/myheartcounts/anna_code/feature_extraction/6minwalk" 
prefix="6minwalk_"
files<-list.files(path=path,pattern=paste(prefix,"*",sep=""),full.names=T,recursive=FALSE) 
gotfirst_rest=FALSE
gotfirst_walk=FALSE 
for(i in 1:length(files))
{
print(files[i]) 
load(files[i]) 
if(grepl("rest",files[i])==TRUE)
{
#REST DATA 
if(gotfirst_rest==FALSE)
{
full_rest_result_arima<-rest_result_arima 
full_rest_result_fourier<-rest_result_fourier 
full_rest_result_paa_aggregate<-rest_result_paa_aggregate 
full_rest_result_timeseries<-rest_result_timeseries 
full_rest_result_paa<-rest_result_paa 
full_rest_result_svd<-rest_result_svd 
full_rest_result_dwt<-rest_result_dwt
gotfirst_rest=TRUE 
}
else
{
#rbind to existing frame 
full_rest_result_arima<-rbind(full_rest_result_arima,rest_result_arima)
full_rest_result_fourier<-rbind(full_rest_result_fourier,rest_result_fourier) 
full_rest_result_paa_aggregate<-rbind(full_rest_result_paa_aggregate,rest_result_paa_aggregate) 
full_rest_result_timeseries<-rbind(full_rest_result_timeseries,rest_result_timeseries)
full_rest_result_paa<-rbind(full_rest_result_paa,rest_result_paa) 
full_rest_result_svd<-rbind(full_rest_result_svd,rest_result_svd)
for(j in 1:length(full_rest_result_dwt))
{
full_rest_result_dwt[[j]]<-rbind(full_rest_result_dwt[[j]],rest_result_dwt[[j]])
} 
}
}
else
{
#WALK DATA 
if(gotfirst_walk==FALSE)
{
full_walk_result_arima<-walk_result_arima 
full_walk_result_fourier<-walk_result_fourier 
full_walk_result_paa_aggregate<-walk_result_paa_aggregate 
full_walk_result_timeseries<-walk_result_timeseries 
full_walk_result_paa<-walk_result_paa 
full_walk_result_svd<-walk_result_svd 
full_walk_result_dwt<-walk_result_dwt
gotfirst_walk=TRUE 
}
else
{
full_walk_result_arima<-rbind(full_walk_result_arima,walk_result_arima)
full_walk_result_fourier<-rbind(full_walk_result_fourier,walk_result_fourier) 
full_walk_result_paa_aggregate<-rbind(full_walk_result_paa_aggregate,walk_result_paa_aggregate) 
full_walk_result_timeseries<-rbind(full_walk_result_timeseries,walk_result_timeseries)
full_walk_result_paa<-rbind(full_walk_result_paa,walk_result_paa) 
full_walk_result_svd<-rbind(full_walk_result_svd,walk_result_svd)
for(j in 1:length(full_walk_result_dwt))
{
full_walk_result_dwt[[j]]<-rbind(full_walk_result_dwt[[j]],walk_result_dwt[[j]])
}
}
}
}

#SAVE THE CONCATENATED DATA FRAMES 
save(full_walk_result_arima,full_walk_result_fourier,full_walk_result_paa_aggregate,full_walk_result_timeseries,full_walk_result_paa,full_walk_result_svd,full_walk_result_dwt,full_rest_result_arima,full_rest_result_fourier,full_rest_result_paa_aggregate,full_rest_result_timeseries,full_rest_result_paa,full_rest_result_svd,full_rest_result_dwt,file="6minwalk_concatenated")