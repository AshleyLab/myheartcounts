rm(list=ls())
#load('full_breakpoints_2') 
load('full_breakpoints_50') 
load('full_breakpoints_100') 
load('full_breakpoints_200') 
source('helpers.R') 
library(data.table) 
#library(ggplot2)
#START WITH 200-point MAJORITY VOTE 

#normalize! 
data=subset(features_200,select=c("stationary_day","stationary_end","changes_day","changes_end"))
data$cur_subject=NULL 
data$changes_day=data$changes_day/max(data$changes_day)
data$changes_end=data$changes_end/max(data$changes_end) 
fit=kmeans(data,6,nstart=10)
data$cluster=factor(fit$cluster)
data$changes_day=features_200$changes_day 
data$changes_end=features_200$changes_end
data$subject=features_200$cur_subject
save(data,file="activity_state_clusters_200.bin") 