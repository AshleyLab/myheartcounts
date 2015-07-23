#RESOURCES 
#http://stats.stackexchange.com/questions/50807/features-for-time-series-classification
#https://github.com/nickgillian/grt/blob/master/GRT/FeatureExtractionModules/FFT/FFT.h
#https://cran.r-project.org/web/views/TimeSeries.html


#EXTRACTS FEATURES FROM A TIMESERIES SIGNAL, RETURNS A DATAFRAME
library(wavelets) 
library(data.table) 
library(moments)
library(pracma) 


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
#print(l)
names(result)<-l
browser() 
return(result) 
}

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
}


#takes a difference between the last and first timestamp and divides by the number of samples
#to estimate the sampleing frequency
get_fs<-function(x,subject)
{

}

#frequencies of the k peaks in amplitude in the DFTs for the detrended d dimensions
#fs represents sampling frequency 
fourier_transform_features<-function(x,fs,subject)
{
l <- length(x)
dft <- fft(detrend(x))/l
amplitude <- 2*abs(dft[1:l/2])
quantiles <- quantile(amplitude,probs=seq(0,1,0.1))
#TOP 10 DOMINANT FREQUENCIES

#MAX FREQ TO SPECTRUM RATIO

#CENTROID FREQUENCY

#SPECTRAL POWER

#MAX AMPLITUDE

#STORE FEATURES IN A DATAFRAME


}




































