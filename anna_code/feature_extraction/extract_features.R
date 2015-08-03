#EXTRACTS FEATURES FROM A TIMESERIES SIGNAL, RETURNS A DATAFRAME

#RESOURCES 
#FFT & TIME SERIES 
#http://stats.stackexchange.com/questions/50807/features-for-time-series-classification
#https://github.com/nickgillian/grt/blob/master/GRT/FeatureExtractionModules/FFT/FFT.h
#https://cran.r-project.org/web/views/TimeSeries.html

source("helpers.R")
source("parameters.R")

library(wavelets) 
library(data.table) 
library(moments)
library(pracma) 
require(numDeriv)
library(Peaks)
library.dynam('Peaks', 'Peaks', lib.loc=NULL)


##############################################################################################################
#Orders of the autoregressive (AR), integrated (I) and moving average (MA) part of an estimated ARIMA model
arima_features<-function(x,subject)
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

##############################################################################################################

#TIME DOMAIN FEATURES 
ts_features<-function(x,subject)
{ 
  N=length(x)
  
  #SIMPLE FEATURES 
  mean_val<-mean(x)
  var_val<-var(x)
  kurtosis_val<-kurtosis(x)
  skewness_val<-skewness(x)
  min_val<-min(x)
  max_val<-max(x)
  moments_all<-all.moments(x,order.max=10)
  
  #ADDITIONAL FROM Phinyomark, Nuidod, Phukpattaranont, Limsakul 
  integral=sum(x) #integral 
  mav=(1/N)*sum(abs(x)) #Mean absolute value 
  mmav=get_mmav(x) #modified mean absolute value 
  ssi=sum(abs(x)^2) #simple square integral 
  rms=sqrt(ssi/N) #root mean square
  v3=(((abs(x))^3)/N)^(1/3) #V3 metric 
  log_detector=exp((1/N)*sum(log(abs(x))))#Log detector 
  wl=sum(abs(diff(x))) #waveform length 
  aac=wl/N #average amplitude change 
  dasdv=sqrt((1/(N-1))*sum((diff(x))^2))#difference absolute standard deviation value 
  mfl=log10(sqrt(sum(diff(rev(x))^2)))#maximum fractal length 
  myop=(1/N)*length(subset(x,abs(x)>threshold))
  wamp=length(subset(x,abs(diff(x))>threshold))
  zc=get_zero_crossing(x) #zero crossing 
  #STORE IN A DATAFRAME 
  result<-data.frame(t(c(mean_val,var_val,kurtosis_val,skewness_val,min_val,max_val,moments_all,integral,mav,mmav,ssi,rms,v3,log_detector,wl,aac,dasdv,mfl,myop,wamp,zc)),row.names=subject)
  
  l <- list();
  for(i in 1:10)
  {
    l<-c(l,c=paste('moment',i,sep=""))
  }
  names(result)<-c("Mean","Variance","Kurtosis","Skewness","Min","Max",l,"Integral","MAV","MMAV","SSI","RMS","V3","LOG","WL","AAC","DASDV","MFL","MYOP","WAMP","ZC")
  return(result)
}

##############################################################################################################


dwt_transform_features <- function(x,subject)
{
  #TAKE THE DWT TRANSFORM
  #Get the filter and the number of levels from the Parameters file
  #To clarify "W" are the wavelet (detail) coefficients; "V" are the scaling (approximation) coefficients
  dwt_x <- dwt(x,filter = filter,n.level = nlevels)
  #Extract a feature vector at each of the levels
  feature_vectors=list() 
  for (i in 1:nlevels)
  {
    #GET THE TOTAL ENERGY AT THE LEVEL
    a_energy = sum((dwt_x@V[[i]]) ^ 2)
    d_energy = 0
    d_energy_components = c()
    EDR_d_names=c() 
    for (j in 1:i)
    {
      d_energy_component = sum((dwt_x@W[[j]]) ^ 2)
      d_energy_components = c(d_energy_components,d_energy_component)
      d_energy = d_energy + d_energy_component
      EDR_d_names=c(EDR_d_names,paste("EDR_d",j,sep=""))
    }
    total_energy = a_energy + d_energy
    
    #GET THE ENERGY RATIOS AT THE LEVEL (Ayrulu-Erdem & Barshan, doi:10.3390/s110201721)
    EDR_a = a_energy / total_energy
    EDR_d = d_energy_components / total_energy
    
    #GET THE FEATURES INCORPORATING ENERGY AND COEFFICIENTS
    min_EDR_d = min(EDR_d)
    max_EDR_d = max(EDR_d)
    mean_EDR_d = mean(EDR_d)
    if(length(d_energy_components)==1)
    {
      var_EDR_d=0 
    }
    else
    {
    var_EDR_d = var(EDR_d)
    }
    #normalized means of decomposition coefficients
    means = c(mean(dwt_x@V[[i]]))
    mean_names=c("mean_scaled")
        for (j in 1:i)
    {
      means = c(means,mean(dwt_x@W[[j]]))
      mean_names=c(mean_names,paste("means_wav",j,sep=""))
        }
    #means = normalize(means)
    
    #normalized variances of decomposition coefficients
    vars = c(var(dwt_x@V[[i]]))
    var_names=c("var_scaled")
    for (j in 1:i)
    {
      vars = c(vars,var(dwt_x@W[[j]]))
      var_names=c(var_names,paste("var_wav",j,sep=""))
    }
    #vars = normalize(vars)
    
    #combine into a dataframe 
    level_features<-data.frame(t(c(total_energy,EDR_a,EDR_d,min_EDR_d,max_EDR_d,mean_EDR_d,var_EDR_d,means,vars)),row.names=subject)
    names(level_features)<-(c("TotalEnery","EDR_a",EDR_d_names,"min_EDR_d","max_EDR_d","mean_EDR_d","var_EDR_d",mean_names,var_names))
    feature_vectors[[i]]=level_features
  }
  return(feature_vectors) 
}
##############################################################################################################

#frequencies of the k peaks in amplitude in the DFTs for the detrended d dimensions
#fs represents sampling frequency 
fourier_transform_features<-function(x,timestamps,subject)
{ 
  l <- length(x)
  outputvals<-get_fs(timestamps)
  fs<-outputvals[1] 
  duration<-outputvals[2] 
  #coerce signal into a time-series object
  data_ts<-ts(detrend(x),1,as.integer(outputvals['delta']),as.integer(outputvals['fs'])) 
  s<-spectrum(data_ts) # get the spectral density, this calls fft internally 
  #PULL OUT FEATURES!
  
  centroid<-sum(s$frequency*s$spec)/sum(s$spec) #same as mean frequency  
  powerspecratio<-max(s$spec)/sum(s$spec) #Power spectrum ratio 
  power<-sum(s$spec) #total power 
  mean_power<-mean(s$spec) #mean power 
  max_spec<-max(s$spec) #max spectrum 
  cdf_spec<-cdf(s$spec) 
  median_cdf_index<-min(which(cdf_spec >=0.5))
  median_freq=s$freq[median_cdf_index]#median frequency 
  moment1<-sum(s$freq*s$spec) 
  moment2<-sum((s$freq)^2*s$spec) 
  moment3<-sum((s$freq)^3*s$spec)
  

  #TOP 10 DOMINANT FREQUENCIES
  pi<-findpeaks(s$spec)
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
  top_freqs<-df$uniq_f[1:10]
  
  #STORE FEATURES IN A DATAFRAME
  subject<-subject 
  result<-data.frame(t(c(centroid,maxfreqspecratio,power,mean_power,max_spec,top_freqs)),row.names=subject)
  names_vec<-c("FFT_centroid","FFT_MaxFreqSpecRatio","FFT_Power","FFT_MeanPower","FFT_MaxSpec")  
  for(i in 1:10)
  {
    names_vec<-c(names_vec,c=paste('FFT_top_freq',i,sep=""))
  }
  names(result)<-names_vec  
  return(result)
}
##############################################################################################################