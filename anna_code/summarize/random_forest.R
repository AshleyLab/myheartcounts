rm(list=ls())
library(randomForest)
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
n_train=0.8*nrow(data)
train_indices=sample(nrow(data),n_train,replace=FALSE)
train_split=data[train_indices,]
test_split=data[-train_indices,]

ytrain=train_split$MeanDailySteps
unique_day_field=which(names(data)=="MeanDailySteps")[1]
xtrain=train_split[, -unique_day_field]
ytest=test_split$UniqueDays
xtest=test_split[,-unique_day_field] 

forest=randomForest(y=ytrain,
                    x=xtrain,
                    xtest=xtest,
                    ytest=ytest,
                    keep.forest=TRUE,
                    importance=TRUE,
                    nTrees=10)
featImp=as.data.table(importance(forest))
write.table(featImp,"rf_mean_daily_steps_feat_importance.tsv",sep='\t',row.names=TRUE,col.names=TRUE)
 