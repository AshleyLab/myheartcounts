#RESOURCES 
#http://stats.stackexchange.com/questions/50807/features-for-time-series-classification
#https://github.com/nickgillian/grt/blob/master/GRT/FeatureExtractionModules/FFT/FFT.h
#https://cran.r-project.org/web/views/TimeSeries.html


#EXTRACTS FEATURES FROM A TIMESERIES SIGNAL, RETURNS A DATAFRAME
library(wavelets) 
library(data.table) 
library(moments)
library(pracma) 
require("numDeriv")
library("Peaks")
library.dynam('Peaks', 'Peaks', lib.loc=NULL)



#Orders of the autoregressive (AR), integrated (I) and moving average (MA) part of an estimated ARIMA model
arima_featuresf<-function(x,subject)
{
  ncoef<-30
  acf_coef=acf(x,ncoef) 
  pacf_coef=pacf(x,ncoef) 
  result<-data.frame(t(c(acf_coef$acf,pacf_coef$acf)),row.names=subject)
  #add names for the data frame
  l <- list();
  for(i in 1:30)
  {
    l<-c(l,c=paste('autocor',i,sep=""))
  }
  for(i in 1:31)
  {
    l<-c(l,c=paste('pautocor',i,sep=""))
  }
  names(result)<-l
  return(result) 
}
result<-data.frame(t(c(acf_coef$acf,pacf_coef$acf)),row.names=subject)

#TIME DOMAIN FEATURES 
#SIMPLE STATISTICS: MEAN,VARIANCE,IQR,KURTOSIS,SKEW,MIN,MAX,FIRST 10 MOMENTS
simple_stat_features<-function(x,subject)
{
  mean_val<-mean(x)
  var_val<-var(x)
  kurtosis_val<-kurtosis(x)
  skewness_val<-skewness(x)
  min_val<-min(x)
  max_val<-max(x)
  moments_all<-all.moments(x,order.max=10)
  #STORE IN A DATAFRAME 
  result<-data.frame(t(c(mean_val,var_val,kurtosis_val,skewness_val,min_val,max_val,moments_all)),row.names=subject)
  names(result)<-c("Mean","Variance","Kurtosis","Skewness","Min","Max","Moments")
  return(result)
}


#takes a difference between the last and first timestamp and divides by the number of samples to estimate the sampleing frequency
get_fs<-function(x)
{
  if(typeof(x)=="double")
  {
    delta<-x[length(x)]-x[1]
  }
  else
  {
    #convert from string to timestamp
    last <- strptime(x[length(x)],"%Y-%m-%dT%H:%M:%S")
    first<-strptime(x[1],"%Y-%m-%dT%H:%M:%S")
    delta<-as.numeric(difftime(last,first,units="secs"))
  }
  fs=length(x)/delta
  return(c(fs=fs,delta=delta)) 
}

#frequencies of the k peaks in amplitude in the DFTs for the detrended d dimensions
#fs represents sampling frequency 
fourier_transform_features<-function(x,timestamps,subject)
{ fourier_transform_features<-data.frame() 
  l <- length(x)
  outputvals<-get_fs(timestamps)
  fs<-outputvals[1] 
  duration<-outputvals[2] 
  #coerce signal into a time-series object
  data_ts<-ts(detrend(x),1,as.integer(outputvals['delta']),as.integer(outputvals['fs'])) 
  s<-spectrum(data_ts) # get the spectral density, this calls fft internally 
  #PULL OUT FEATURES!
  centroid<-sum(s$frequency*s$spec)/sum(s$spec)
  maxfreqspecratio<-max(s$spec)/sum(s$spec)
  power<-sum(s$spec)
  max_spec<-max(s$spec)
  #TOP 10 DOMINANT FREQUENCIES
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
  #STORE FEATURES IN A DATAFRAME
  result<-data.frame(t(c(centroid,maxfreqspecratio,power,max_spec,top_freqs)),row.names=subject)
  names_vec<-c("FFT_centroid","FFT_MaxFreqSpecRatio","FFT_Power","FFT_MaxSpec")  
  for(i in 1:10)
  {
    names_vec<-c(names_vec,c=paste('FFT_top_freq',i,sep=""))
  }
  names(result)<-names_vec  
  return(result)
}




































