#RESOURCES 
#http://stats.stackexchange.com/questions/50807/features-for-time-series-classification
#https://github.com/nickgillian/grt/blob/master/GRT/FeatureExtractionModules/FFT/FFT.h
#https://cran.r-project.org/web/views/TimeSeries.html
rm(list=ls())

#EXTRACTS FEATURES FROM A TIMESERIES SIGNAL, RETURNS A DATAFRAME
library(wavelets) 
library(data.table) 
library(moments)
library(pracma) 
require("numDeriv")
library("Peaks")
library.dynam('Peaks', 'Peaks', lib.loc=NULL)
source("extract_features.R") 

walk_dir<-"/home/anna/6minute_walk_small/acceleration_walk" 
rest_dir<-"/home/anna/6minute_walk_small/acceleration_rest"
files <- list.files(path=walk_dir, pattern="*.tsv", full.names=T, recursive=FALSE)
  data<-fread(files[1],header=T)
  x<-data$x
  y<-data$y
  z<-data$z
  l <- length(x)
  outputvals<-get_fs(data$timestamp)
  fs<-outputvals[1] 
  duration<-outputvals[2] 
  #coerce signal into a time-series object
  data_ts<-ts(detrend(x),1,as.integer(outputvals['delta']),as.integer(outputvals['fs'])) 
  s<-spectrum(data_ts) # get the spectral density, this calls fft internally 
  #GET THE 10 TOP FREQUENCIES 
  pi<-findPeaks(s$spec)
  pi_f<-s$freq[pi]
  pi_s<-s$spec[pi]
  pi_f_round<-round(pi_f)
  uniq_f<-c() 
  uniq_s<-c()
  for(i in unique(pi_f_round))
  {
    f_subset<-which(pi_f_round==i)
    max_spec<-max(pi_s[f_subset])
    uniq_f=c(uniq_f,i)
    uniq_s=c(uniq_s,max_spec)
  }
  points(uniq_f,uniq_s,col="red")
  df<-data.frame(uniq_f,uniq_s)
  df<-df[with(df, order(-uniq_s)), ]
  top_freqs<-df$uniq_f[1:10,]
  