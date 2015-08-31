#contains parameters used in the feature extraction scripts 
value_dir="/home/anna/scg/myheartcounts/anna_code/simband_local/values"

#data directories 
accel_walk_dir<-'/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/6minute_walk/acceleration_walk'
accel_rest_dir<-'/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/6minute_walk/acceleration_rest'
weekday_dir<-'/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/weekday'
weekend_dir<-'/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/weekend'

#age, sex, other categorical information 
metadata<-'/srv/gsfs0/projects/ashley/common/myheart/results/Non_timeseries_data_07012014.tsv'

#Pedometer for QC 
pedometer_dir<-'/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/6minute_walk/pedometer'
 

interval<-500 #number of data points to use for sampling 

#DWT params 
nlevels <-8 
filter<-'d4' #4th order Daubechies used as mother wavelet 
threshold<-0.1 

#FT params 
low_band_low=1
low_band_high=20
high_band_low=20
high_band_high=50 

#Piecewise Aggregate Approximation (PAA) params 
chunks_period=10 #Split one period of the signal into 10 chunks
