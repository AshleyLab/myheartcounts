rm(list=ls())
library(wavelets) 
library(data.table)
source('extract_features.R')
source('helpers.R') 
source('parameters.R') 


#############################################################################################
#extract features for acceleration walk
gotfirst=FALSE
files <- list.files(path=value_dir, pattern="values*", full.names=T, recursive=FALSE)
for (i in 1:length(files)){
    success<-FALSE
    #STORE THE COEFFICIENTS IN THE FEATURE MATRIX THAT WE ARE BUILDING
    cur_subject<-paste(strsplit(files[i],"_")[[1]][2],strsplit(files[i],"_")[[1]][3],strsplit(files[i],"_")[[1]][4],sep=".")
    #cur_subject<-strsplit(files[i],"_")[[1]]
    #cur_subject<-cur_subject[length(cur_subject)]
    #cur_subject<-gsub(".tsv","",cur_subject)
    print(cur_subject) 
    signal_ecg<-as.data.frame(read.table(files[i],header=F,stringsAsFactors=FALSE,sep="\t"))
    signal_ecg=signal_ecg
    timestamp_ecg<-signal_ecg$V1/1000
    signal_ecg<-as.numeric(signal_ecg$V2) 
    l_ecg <- length(signal_ecg) 
    outputvals_ecg<-get_fs(timestamp_ecg)
    fs_ecg<-outputvals_ecg[1] 
    duration_ecg<-outputvals_ecg[2] 

     if(gotfirst==FALSE)
    {
    #get the ecg features 
    ecg_arima<-arima_features(signal_ecg,cur_subject)
    ecg_timeseries<-ts_features(signal_ecg,fs_ecg,duration_ecg,cur_subject) 
    ecg_fourier<-fourier_transform_features(signal_ecg,fs_ecg,duration_ecg,cur_subject)
    ecg_dwt<-dwt_transform_features(signal_ecg,cur_subject)
    ecg_paa=piecewise_aggregate(signal_ecg, duration_ecg, periodic=TRUE,cur_subject)
    ecg_svd=svd_features(signal_ecg,cur_subject)
    gotfirst=TRUE
    }
    else
    {
    ecg_arima<-rbind(ecg_arima,arima_features(signal_ecg,cur_subject))
    print("arima") 
    ecg_timeseries<-rbind(ecg_timeseries,ts_features(signal_ecg,fs_ecg,duration_ecg,cur_subject))
    print("ts") 
    ecg_fourier<-rbind(ecg_fourier,fourier_transform_features(signal_ecg,fs_ecg,duration_ecg,cur_subject)) 
    print("fourier")
    newtransform<-dwt_transform_features(signal_ecg,cur_subject)
    for(j in 1:length(ecg_dwt))
    {
    ecg_dwt[[j]]<-rbind(ecg_dwt[[j]],newtransform[[j]])
    }
    print("dwt") 
    ecg_paa<-rbind(ecg_paa,piecewise_aggregate(signal_ecg,duration_ecg,periodic=TRUE,cur_subject))
    print("paa") 
    ecg_svd<-rbind(ecg_svd,svd_features(signal_ecg,cur_subject)) 
    print("svd") 
    }
}
print("writing output binary ecg  file") 
save(ecg_arima,ecg_timeseries,ecg_fourier,ecg_dwt,ecg_paa,ecg_svd,file="ECG_subjects")
ecg_dwt<-ecg_dwt[[7]]
rownames(ecg_timeseries)=rownames(ecg_fourier)

#This also needs to change
#get the set of subjects that havet data in each of the data frames 
subjects1<-rownames(ecg_arima)
subjects2<-rownames(ecg_dwt)
subjects3<-rownames(ecg_fourier)
subjects4<-rownames(ecg_paa)
subjects5<-rownames(ecg_svd)
subjects6<-rownames(ecg_timeseries)


#This needs to change
common=subjects1
common=intersect(common,subjects2)
common=intersect(common,subjects3)
common=intersect(common,subjects4)
common=intersect(common,subjects5)
common=intersect(common,subjects6)


ecg_arima<-ecg_arima[common,]
ecg_dwt<-ecg_dwt[common,]
ecg_fourier<-ecg_fourier[common,]
ecg_paa<-ecg_paa[common,]
ecg_svd<-ecg_svd[common,]
ecg_timeseries<-ecg_timeseries[common,]

#preface the names of each dataframe with ecg or weekend 
ecg_df=cbind(ecg_arima,ecg_dwt,ecg_fourier,ecg_paa,ecg_svd,ecg_timeseries)

names<-names(ecg_df)
ecg_names<-c() 
for(i in 1:length(names))
{
  
  ecg_names<-c(ecg_names,paste(names[i],"_ecg",sep=""))
}
names(ecg_df)<-ecg_names 

#use cbind to paste dataframes together 
save(ecg_df,file='ECG8_merged')
