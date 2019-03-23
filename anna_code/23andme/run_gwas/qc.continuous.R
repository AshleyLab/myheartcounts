rm(list=ls())
data=read.table("continuous.phenotypes.formatted.csv",header=TRUE,sep='\t')
data[data==-1000]=NA

library(ggplot2)
tocheck=c("vigorous_act",
          'heartAgeDataSystolicBloodPressure',
          'moderate_act',
          'running_Fract',
          'running_Mins',
          'sleep_time',
          'sleep_time1',
          'stationary_Fract',
          'sugar_drinks',
          'bloodPressureInstruction'
          )
data$vigorous_act[data$vigorous_act>300]=NA
# data$heartAgeDataSystolicBloodPressure[data$heartAgeDataSystolicBloodPressure>150]=NA
data$moderate_act[data$moderate_act>500]=NA
data$running_Fract[data$running_Fract>0.03]=NA
data$sleep_time[data$sleep_time>3]=NA
data$sleep_time[data$sleep_time< -4]=NA
# data$sleep_time1[data$sleep_time1>10]=NA
data[is.na(data)]=-1000
write.table(data,file="continuous.phenotypes.formatted.csv",sep='\t',quote=FALSE,row.names=FALSE,col.names=TRUE)
#for (i in seq(3,ncol(data)))
#{
#  print(ggplot(data,aes(x=data[,i]))+
#    geom_histogram(bins=100)+
#    ggtitle(names(data)[i]))
#  browser() 
#}
