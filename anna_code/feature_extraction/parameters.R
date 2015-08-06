#contains parameters used in the feature extraction scripts 

#data directories 
accel_walk_dir<-'/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/6minute_walk/acceleration_walk'
accel_rest_dir<-'/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/6minute_walk/acceleration_rest'

#age, sex, other categorical information 
metadata<-'/srv/gsfs0/projects/ashley/common/myheart/results/Non_timeseries_data_07012014.tsv'

#Pedometer for QC 
pedometer_dir<-'/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/6minute_walk/pedometer'
 

#6 minute walk filtering 
changepoint_thresh<-10 
nlevels<-10
min_valid_duration<-355 #subject must have 6 minutes +/- 5 seconds of data to be used in the analysismax_valid_duration<-365 
min_valid_rest_duration<-180
max_valid_rest_duration<-365 

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
