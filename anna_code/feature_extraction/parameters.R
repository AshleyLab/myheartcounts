#contains parameters used in the feature extraction scripts 

interval<-1000 #number of data points to use for sampling 

#DWT params 
nlevels <-8 
filter<-'d4' #4th order Daubechies used as mother wavelet 
threshold<-0.1 

#FT params 
low_band_low=1
low_band_high=5
high_band_low=5
high_band_high=50 

#Piecewise Aggregate Approximation (PAA) params 
chunks_period=10 #Split one period of the signal into 10 chunks
chunks_full_signal=24 #Split the entire signal into 24 chunks (this assumes 1 day's worth of signal, as in the motion tracker) 
