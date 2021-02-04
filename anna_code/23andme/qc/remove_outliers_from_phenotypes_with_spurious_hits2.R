rm(list=ls())
data=read.table("continuous.phenotypes.formatted.cleanedupskew.csv",header=TRUE,sep='\t')
data[data==-1000]=NA
#remove outliers from phenotypes that yield many spurious GWAS hits 
data$heartAgeDataDiastolicBloodPressure[data$heartAgeDataDiastolicBloodPressure < -20]=NA
data$heartAgeDataDiastolicBloodPressure[data$heartAgeDataDiastolicBloodPressure > 20]=NA

data$moderate_act[data$moderate_act>500]=NA
data$sleep_time1[data$sleep_time1>5]=NA
data$vigorous_act[data$vigorous_act >300]=NA
data[is.na(data)]=-1000
write.table(data,"continuous.phenotypes.formatted.cleanedupskew2.csv",quote=FALSE,sep='\t',row.names=FALSE,col.names = TRUE)
