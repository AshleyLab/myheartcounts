rm(list=ls())
library(data.table)
#ALL FEATURES 
#PCA 
 d<-as.data.frame(read.table("motiontracker_data.txt",row.name=1,header=T)) 
# pr.all=prcomp(d,scale=TRUE) 
# png('pca_all.png') 
# biplot(pr.all,scale=0,xlabs=rep(".",17062))
# dev.off() 

# png('pca_all_1_3.png')
# biplot(pr.all,choices=c(1,3),scale=0,xlabs=rep(".",17062))
# dev.off() 

# png('pca_all_2_3.png')
# biplot(pr.all,choices=c(2,3),scale=0,xlabs=rep(".",17062))
# dev.off() 


# #SCREE PLOT 
# pr.all.var=pr.all$sdev^2 
# pve.all=pr.all.var/sum(pr.all.var) 
# png('pca_all_scree.png') 
# plot(pve.all,xlab="Principal Component for All-Features",ylab="Proportion of Variance Explained",ylim=c(0,1),type="b") 
# dev.off() 


# #WAVELETS 
# wavelets<-d[,1:20] 
# proportions<-d[,21:length(names(d))]

# pr.wavelet=prcomp(wavelets,scale=TRUE) 
# pr.proportion=prcomp(proportions,scale=TRUE) 

# png('pca_wavelet.png')
# biplot(pr.wavelet,scale=0,xlabs=rep(".",17062))
# dev.off() 

# png('pca_wavelet_1_3.png')
# biplot(pr.wavelet,choices=c(1,3),scale=0,xlabs=rep(".",17062))
# dev.off() 

# png('pca_wavelet_2_3.png')
# biplot(pr.wavelet,choices=c(2,3),scale=0,xlabs=rep(".",17062))
# dev.off() 


# #SCREE PLOT 
# pr.wavelet.var=pr.wavelet$sdev^2 
# pve.wavelet=pr.wavelet.var/sum(pr.wavelet.var) 
# png('pca_wavelet_scree.png') 
# plot(pve.wavelet,xlab="Principal Component for Wavelet-Features",ylab="Proportion of Variance Explained",ylim=c(0,1),type="b") 
# dev.off() 

# #PROPORTIONS 
# png('pca_proportion.png')
# biplot(pr.proportion,scale=0,xlabs=rep(".",17062))
# dev.off() 


# png('pca_proportion_1_3.png')
# biplot(pr.proportion,choices=c(1,3),scale=0,xlabs=rep(".",17062))
# dev.off() 

# png('pca_proportion_2_3.png')
# biplot(pr.proportion,choices=c(2,3),scale=0,xlabs=rep(".",17062))
# dev.off() 

# #SCREE PLOT 
# pr.proportion.var=pr.proportion$sdev^2 
# pve.proportion=pr.proportion.var/sum(pr.proportion.var) 
# png('pca_proportion_scree.png') 
# plot(pve.proportion,xlab="Principal Component for Proportion-Features",ylab="Proportion of Variance Explained",ylim=c(0,1),type="b") 
# dev.off()  


#DELTA OF WEEKEND AND WEEKDAY ACTIVITY 
delta_w1<-abs(d$day1-d$end1)
delta_w2<-abs(d$day2-d$end2)
delta_w3<-abs(d$day3-d$end3) 
delta_w4<-abs(d$day4-d$end4) 
delta_w5<-abs(d$day5-d$end5) 
delta_w6<-abs(d$day6-d$end6)
delta_w7<-abs(d$day7-d$end7)
delta_w8<-abs(d$day8-d$end8)
delta_w9<-abs(d$day9-d$end9)
delta_w10<-abs(d$day10-d$end10)
delta_automotive<-abs(d$automotive_day-d$automative_end)
delta_stationary<-abs(d$stationary_day-d$stationary_end)
delta_unknown<-abs(d$unknown_day-d$unknown_end)
delta_walking<-abs(d$walking_day-d$walking_end)
delta_cycling<-abs(d$cycling_day-d$cycling_end)
delta_running<-abs(d$running_day-d$running_end)
delta_num_datapoints<-abs(d$num_datapoints_day-d$num_datapoints_end)
delta_mean_interval<-abs(d$mean_interval_day-d$mean_interval_end)
deltas<-data.frame(delta_w1,delta_w2,delta_w3,delta_w4,delta_w5,delta_w6,delta_w7,delta_w8,delta_w9,delta_w10,delta_automotive,delta_stationary,delta_unknown,delta_walking,delta_cycling,delta_running,delta_num_datapoints,delta_mean_interval,row.names=row.names(d)) 

pr.deltas=prcomp(deltas,scale=TRUE) 
png('pca_deltas.png') 
biplot(pr.deltas,scale=0,xlabs=rep(".",17062))
dev.off() 

png('pca_deltas_1_3.png')
biplot(pr.deltas,choices=c(1,3),scale=0,xlabs=rep(".",17062))
dev.off() 

png('pca_deltas_2_3.png')
biplot(pr.deltas,choices=c(2,3),scale=0,xlabs=rep(".",17062))
dev.off() 


#SCREE PLOT 
pr.deltas.var=pr.deltas$sdev^2 
pve.deltas=pr.deltas.var/sum(pr.deltas.var) 
png('pca_deltas_scree.png') 
plot(pve.deltas,xlab="Principal Component for Deltas-Features",ylab="Proportion of Variance Explained",ylim=c(0,1),type="b") 
dev.off() 
