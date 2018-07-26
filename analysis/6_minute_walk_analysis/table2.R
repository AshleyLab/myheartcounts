rm(list=ls())
library(data.table)
meta=data.frame(read.table("NonTimeSeries.txt",header=T,sep='\t',stringsAsFactors = FALSE))
steps=data.frame(read.table("Steps_6MW.txt",header=T,sep='\t',stringsAsFactors = FALSE))
meters=data.frame(read.table("Displacement_6MW.txt",header=T,sep='\t',stringsAsFactors = FALSE))
fraction=data.frame(read.table("Activity_states_weekday_weekend_total_10022015.tsv",header=T,sep='\t'))
merged=merge(steps,meters,by="Subject",all=TRUE)
merged=merge(merged,meta,by="Subject",all=TRUE)
merged=merge(merged,fraction,by="Subject",all=TRUE)
merged$Vig_and_Moder=merged$vigorous_act+merged$moderate_act
merged$Active=merged$RunningTotal+merged$WalkingTotal+merged$CyclingTotal 
data=subset(merged,select=c("Subject","Steps","Meters","Age","Sex","Vig_and_Moder","sleep_time","Active"))
save(data,file="Table2.rData") 


