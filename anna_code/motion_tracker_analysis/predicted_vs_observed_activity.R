rm(list=ls())
library(data.table)
library(ggplot2)

predicted=data.frame(read.table('NonTimeSeries.txt',header=T,sep='\t'))
observed=data.frame(read.table("Activity_states_weekday_weekend_total.tsv",header=T,sep='\t'))
merged=merge(predicted,observed,by="Subject")
merged$moderate_act=merged$moderate_act/(24*60)
merged$vigorous_act=merged$vigorous_act/(24*60)
active_total=merged$WalkingTotal+merged$RunningTotal+merged$CyclingTotal
f=glm(active_total~merged$moderate_act+merged$vigorous_act+merged$phys_activity)
