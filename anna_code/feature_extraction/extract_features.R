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
library(normwhn.test)
library(TSclust)
library.dynam('Peaks', 'Peaks', lib.loc=NULL)



##############################################################################################################
arima_features<-function(x,subject)
{

  ncoef<-10
  acf_covar_coef=acf(x,type="covariance",ncoef,plot=FALSE)

  acf_coef=acf(x,ncoef,plot=FALSE) 

  pacf_coef=pacf(x,ncoef,plot=FALSE) 
  
  result<-data.frame(t(c(acf_covar_coef$acf, acf_coef$acf,pacf_coef$acf)),row.names=subject)
  #add names for the data frame
  l <- list();
  for(i in 1:(ncoef+1))
  {
    l<-c(l,c=paste('autocovar',i,sep=""))
  }
  
  for(i in 1:(ncoef+1))
  {
    l<-c(l,c=paste('autocor',i,sep=""))
  }
  for(i in 1:ncoef)
  {
    l<-c(l,c=paste('pautocor',i,sep=""))
  }
  names(result)<-l
  return(result) 
}

##############################################################################################################

#TIME DOMAIN FEATURES 
ts_features<-function(x,fs,duration,subject)
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
  mad=(1/N)*sum(abs(x-mean_val))#mean absolute deviation 
  mmav=get_mmav(x) #modified mean absolute value 
  ssi=sum(abs(x)^2) #simple square integral 
  rms=sqrt(ssi/N) #root mean square
  v3=((1/N)*sum(abs(x)^3))^(1/3) #V3 metric 
  log_detector=exp((1/N)*sum(log(abs(x))))#Log detector 
  wl=sum(abs(diff(x))) #waveform length 
  aac=wl/N #average amplitude change 
  dasdv=sqrt((1/(N-1))*sum((diff(x))^2))#difference absolute standard deviation value 
  mfl=log10(sqrt(sum(diff(rev(x))^2)))#maximum fractal length 
  myop=(1/N)*length(subset(x,abs(x)>threshold))
  wamp=length(subset(x,abs(diff(x))>threshold))
  zc=get_zero_crossing(x) #zero crossing 
  
  
  #Time between peaks for a  point sample in the middle (i.e. around 3 minute mark for 6 minute walk)
  sample_start=length(x)/2-interval/2 
  sample_end=sample_start+interval
  sample_subset=x[sample_start:sample_end]
  peaks<-findpeaks(-1*sample_subset,minpeakheight = 0.5)
  mean_time<-as.numeric(mean(diff(peaks[,2]))*(1/fs))
 
  #STORE IN A DATAFRAME 
  result<-data.frame(t(c(mean_val,var_val,kurtosis_val,skewness_val,min_val,max_val,moments_all,integral,mav,mad,mmav,ssi,rms,v3,log_detector,wl,aac,dasdv,mfl,myop,wamp,zc,mean_time)))
  
  l <- list();
  for(i in 0:10)
  {
    l<-c(l,c=paste('moment',i,sep=""))
  }
  names(result)<-c("Mean","Variance","Kurtosis","Skewness","Min","Max",l,"Integral","MAV","MAD","MMAV","SSI","RMS","V3","LOG","WL","AAC","DASDV","MFL","MYOP","WAMP","ZC","Mean_Time_BP")
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
    
    #variances of decomposition coefficients
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
fourier_transform_features<-function(x, fs, duration,subject)
{ 
  #coerce signal into a time-series object
  data_ts<-ts(detrend(x),1,as.integer(duration),as.integer(fs)) 
  s<-spectrum(data_ts,plot=FALSE) # get the spectral density, this calls fft internally 
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
  #frequency ratio: A measure termed the frequency
  #ratio is defined as the ratio of the power in the high frequency band from 8 to 24 Hz
  #compared to the power in the low frequency band from 3 to 5 Hz
  freq_ratio<-get_frequency_ratio(s,low_band_low,low_band_high,high_band_low,high_band_high)
  
  #TOP 10 DOMINANT FREQUENCIES
  pi<-findpeaks(s$spec)[,2] #only store the index of the peak maximum 
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
  #points(uniq_f,uniq_s,col="red")
  df<-data.frame(uniq_f,uniq_s)
  df<-df[with(df, order(-uniq_s)), ]
  top_freqs<-df$uniq_f[1:10]
  
  #QUANTILES OF THE SPECTRUM (BINNING)
  quant<-as.vector(quantile(s$spec))
  
  #STORE FEATURES IN A DATAFRAME
  subject<-subject 
  result<-data.frame(t(c(centroid,powerspecratio,power,mean_power,max_spec,top_freqs,quant)),row.names=subject)
  names_vec<-c("FFT_centroid","FFT_MaxFreqSpecRatio","FFT_Power","FFT_MeanPower","FFT_MaxSpec")  
  for(i in 1:10)
  {
    names_vec<-c(names_vec,c=paste('FFT_top_freq',i,sep=""))
  }
  for(i in 1:5)
  {
    names_vec<-c(names_vec,c=paste('FFT_quantile',i,sep=""))
  }
  names(result)<-names_vec  
  return(result)
}
##############################################################################################################
#piecewise aggregate approximation
#periodic--> if True, approximation will be made for a single period , if false, approximation will be made for whole signal 
#duration in seconds 
#uses paa function from TSclust 
piecewise_aggregate<-function(x, duration, periodic,subject)
{
  if(periodic==TRUE)
  {
    #isolate a single period using a peak caller 
    p<-get_period(x,interval)
    if(is.null(p))
    {
      print(paste("Could not find signal period for subject",subject,sep=""))
      return(NULL)
    }
    #pad with zeros if datapoints in p is less than the number of chunks 
    if (length(p)<chunks_period)
    {
      p<-c(p,rep(0,chunks_period-length(p)))
    }
    paa_vals<-PAA(p,chunks_period)
  }
  else
  {
    paa_vals<-PAA(x,chunks_full_signal)
  }
  #Store the result in a data frame 
  result<-data.frame(t(paa_vals),row.names=subject)
  names_vec<-c()
  for(i in 1:length(paa_vals))
  {
    names_vec<-c(names_vec,c=paste('paa',i,sep=""))
  }
  names(result)<-names_vec
  return(result)
}
#piecewise aggregate approximation
#periodic--> if True, approximation will be made for a single period , if false, approximation will be made for whole signal 
#duration in seconds 
#uses paa function from TSclust 
piecewise_aggregate_resultant<-function(x,y,z,duration, periodic,subject)
{
  return(piecewise_aggregate(sqrt(x^2+y^2+z^2),duration,periodic,subject))
}

##############################################################################################################
#SVD (Singular Value Decomposition)
svd_features<-function(x, subject)
{
  #Get the initial singular values 
  svd_vals<-svd(x)
  sv_val<-svd_vals$d 
  result<-data.frame(sv_val,row.names=subject)
  names_vec<-c("SVD_val")
  names(result)=names_vec
  return(result)
}
