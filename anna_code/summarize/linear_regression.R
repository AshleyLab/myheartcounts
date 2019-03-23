rm(list=ls())
library(randomForest) 
library(Rborist)
library(gbm)
library(reshape2)
library(ggplot2)
options(warn=-1)
data=read.table("merged_binarized.tsv",header=TRUE,sep='\t',row.names = 1)
#set random seed
set.seed(1234)

#drop any columns that are composed of NA entirely
data=data[colSums(is.na(data)) < nrow(data)]

#fill in missing values via imputation
data <- na.roughfix(data)

#Remove any columns with 0 variance
data=data[sapply(data,var)>0]
data$regionInformation.countryCode=NULL

y=data$UniqueDays
unique_day_field=which(names(data)=="UniqueDays")[1]
x=data[, -unique_day_field]
linearMod=lm(UniqueDays~.,data=data)
write.table(summary(linearMod)$coefficients,"linear_regression_days_in_study.tsv",sep='\t',row.names=TRUE,col.names=TRUE,quote=FALSE)
linearMod=lm(MeanDailySteps~.,data=data)
write.table(summary(linearMod)$coefficients,"linear_regression_mean_daily_steps.tsv",sep='\t',row.names=TRUE,col.names=TRUE,quote=FALSE)


