rm(list=ls())
source("extract_features.R") 
walk_dir<-"/home/anna/6minute_walk_small/acceleration_walk" 
rest_dir<-"/home/anna/6minute_walk_small/acceleration_rest"

files <- list.files(path=walk_dir, pattern="*.tsv", full.names=T, recursive=FALSE)
for (i in 1:1){
    data<-fread(files[i],header=T)
    x<-data$x
    y<-data$y
    z<-data$z 

    cur_subject<-strsplit(files[i],"/")[[1]]
    cur_subject<-cur_subject[length(cur_subject)]
    cur_subject<-gsub(".tsv","",cur_subject)
    print(cur_subject)
    
    result_fourier<-fourier_transform_features(data$x,data$timestamp,cur_subject) 
    #result_dwt<-dwt_transform_features(data$x,cur_subject)
    #result_y<-dwt_transform_features(data$y,cur_subject)
    #result_z<-dwt_transform_features(data$z,cur_subject)

    }
    