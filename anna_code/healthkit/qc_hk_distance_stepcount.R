rm(list=ls())
library(ggplot2)
library(dplyr)
library(tidyr)
data_dir="~/sherlock/data/timeseries_v2/summary"
motion_df=read.table(paste(data_dir,"motion_tracker_combined.txt",sep='/'),header=TRUE,sep='\t')
steps_df=read.table(paste(data_dir,"healthkit_combined.stepcount.txt",sep='/'),header=TRUE,sep='\t')
dist_df=read.table(paste(data_dir,"healthkit_combined.distance.txt",sep='/'),header=TRUE,sep='\t')

#filter to the columns we want 
motion_subset=subset(motion_df,select=c("Subject","DayIndex","Activity","Fraction"))
steps_subset=subset(steps_df,select=c("Subject","DayIndex", "Metric","Value"))
dist_subset=subset(dist_df,select=c("Subject","DayIndex","Metric","Value"))

#merge by subject and day index 
m1=inner_join(motion_subset,steps_subset)
m2=inner_join(m1,dist_subset)