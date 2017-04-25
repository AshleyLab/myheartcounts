rm(list=ls())
library(data.table)
library(ggplot2)
data_sit=data.frame(read.table('diff_hr_sit',header=T,sep='\t'))
dropout_sit=data.frame(read.table('dropped_hr_sit',header=T,sep='\t'))

data_walk=data.frame(read.table('diff_hr_walk',header=T,sep='\t'))
dropout_walk=data.frame(read.table('dropped_hr_walk',header=T,sep='\t'))

data_run=data.frame(read.table('diff_hr_run',header=T,sep='\t'))
dropout_run=data.frame(read.table('dropped_hr_run',header=T,sep='\t'))

data_bike=data.frame(read.table('diff_hr_bike',header=T,sep='\t'))
dropout_bike=data.frame(read.table('dropped_hr_bike',header=T,sep='\t'))

data_max=data.frame(read.table('diff_hr_max',header=T,sep='\t'))
dropout_max=data.frame(read.table('dropped_hr_max',header=T,sep='\t'))

# Notched box plot
par(mfrow=c(2,5))

boxplot(data_sit,xlab="Device",ylab='Steady State BPM - Gold Std.',main="Heart Rate, Sit")
boxplot(data_walk,xlab="Device",ylab='Steady State BPM - Gold Std.',main="Heart Rate, Walk")
boxplot(data_run,xlab="Device",ylab='Steady State BPM - Gold Std.',main="Heart Rate, Run")
boxplot(data_bike,xlab="Device",ylab='Steady State BPM - Gold Std.',main="Heart Rate, Bike")
boxplot(data_max,xlab="Device",ylab='Steady State BPM - Gold Std.',main="Heart Rate, Max Test")

boxplot(dropout_sit,xlab="Device",ylab='Fraction of time with lost data (per subject)',main="Data Loss, Sit")
boxplot(dropout_walk,xlab="Device",ylab='Fraction of time with lost data (per subject)',main="Data Loss, Walk")
boxplot(dropout_run,xlab="Device",ylab='Fraction of time with lost data (per subject)',main="Data Loss, Run")
boxplot(dropout_bike,xlab="Device",ylab='Fraction of time with lost data (per subject)',main="Data Loss, Bike")
boxplot(dropout_max,xlab="Device",ylab='Fraction of time with lost data (per subject)',main="Data Loss, Max")

#ENERGY!
data_sit=data.frame(read.table('diff_energy_sit',header=T,sep='\t'))
dropout_sit=data.frame(read.table('dropped_energy_sit',header=T,sep='\t'))

data_walk=data.frame(read.table('diff_energy_walk',header=T,sep='\t'))
dropout_walk=data.frame(read.table('dropped_energy_walk',header=T,sep='\t'))

data_run=data.frame(read.table('diff_energy_run',header=T,sep='\t'))
dropout_run=data.frame(read.table('dropped_energy_run',header=T,sep='\t'))

data_bike=data.frame(read.table('diff_energy_bike',header=T,sep='\t'))
dropout_bike=data.frame(read.table('dropped_energy_bike',header=T,sep='\t'))

data_max=data.frame(read.table('diff_energy_max',header=T,sep='\t'))
dropout_max=data.frame(read.table('dropped_energy_max',header=T,sep='\t'))

# Notched box plot
par(mfrow=c(2,5))

boxplot(data_sit,xlab="Device",ylab='Steady State Kcal - Gold Std.',main="Kcal, Sit")
boxplot(data_walk,xlab="Device",ylab='Steady State Kcal - Gold Std.',main="Kcal, Walk")
boxplot(data_run,xlab="Device",ylab='Steady State Kcal - Gold Std.',main="Kcal, Run")
boxplot(data_bike,xlab="Device",ylab='Steady State Kcal - Gold Std.',main="Kcal, Bike")
boxplot(data_max,xlab="Device",ylab='Steady State Kcal - Gold Std.',main="Kcal, Max Test")

boxplot(dropout_sit,xlab="Device",ylab='Fraction of time with lost data (per subject)',main="Data Loss, Sit")
boxplot(dropout_walk,xlab="Device",ylab='Fraction of time with lost data (per subject)',main="Data Loss, Walk")
boxplot(dropout_run,xlab="Device",ylab='Fraction of time with lost data (per subject)',main="Data Loss, Run")
boxplot(dropout_bike,xlab="Device",ylab='Fraction of time with lost data (per subject)',main="Data Loss, Bike")
boxplot(dropout_max,xlab="Device",ylab='Fraction of time with lost data (per subject)',main="Data Loss, Max")

