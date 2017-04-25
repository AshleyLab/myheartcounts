library(wavelets) 
library(data.table)

ss<-function(x)
{
  sum(x^2)
}

setwd('/home/anna/r_scripts/')
metadata_file<-'/home/anna/r_scripts/Non_timeseries_filtered.tsv'
meta<-read.table(metadata_file,sep="\t",header=TRUE,row.names=1)
merged<-as.data.frame(meta)

accel<-read.table('acceleration_data.txt')
accel<-as.data.frame(accel)
merged<-merge(accel,metasubset,by="row.names",all.x=TRUE)
rownames(merged)=merged$Row.names 
merged<-merged[2:123]
write.table(merged,file="merged_acceleration_meta.txt")


#QC 
accel_row<-which(rownames(accel) %in% "ff9c601e-6de5-41e7-ade1-561ae0aeb8de")
meta_row<-which(rownames(metasubset) %in% "ff9c601e-6de5-41e7-ade1-561ae0aeb8de")
merged_row<-which(rownames(merged) %in% "ff9c601e-6de5-41e7-ade1-561ae0aeb8de")