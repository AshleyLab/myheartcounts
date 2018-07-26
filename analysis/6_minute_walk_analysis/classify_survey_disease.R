library(tree)
library(data.table)
library(gbm)
rm(list=ls()) #REMOVE OLD VARIABLES FROM ENVIRONMENT 

source('/home/anna/r_scripts/split_data.R')
setwd('/home/anna/r_scripts/')

metadata_file<-'/home/anna/r_scripts/Non_timeseries_filtered2.tsv'
meta<-read.table(metadata_file,sep="\t",header=TRUE,row.names=1)
merged<-as.data.frame(meta)

#DROP TIMESTAMP COLUMNS FOR NOW -- NOT SURE HOW TO USE THEM 
merged$patientWakeUpTime<-NULL 
merged$patientGoSleepTime<-NULL 

#COERCE NUMERICAL VALUES TO FACTORS FOR CATEGORICAL RESPONSES
merged$atwork<-factor(merged$atwork)
merged$phys_activity<-factor(merged$phys_activity)
merged$sleep_time_ActivitySleep<-factor(merged$sleep_time_ActivitySleep)
merged$vascular<-factor(merged$vascular)
merged$medications_to_treat<-factor(merged$medications_to_treat)
merged$heartAgeDataHypertension<-factor(merged$heartAgeDataHypertension)
merged$family_history<-factor(merged$family_history)
merged$sodium<-factor(merged$sodium)
merged$phone_on_user<-factor(merged$phone_on_user)
merged$heartAgeDataHypertension<-factor(merged$heartAgeDataHypertension)

#TRAINING DATA (Age/Age known)
heartAgeDataHypertension.train<-subset(merged,is.na(merged$heartAgeDataHypertension)==FALSE)
heartAgeDataHypertension.test<-subset(merged,is.na(merged$heartAgeDataHypertension))


#RANDOMLY SPLIT TRAINING DATA FOR 2-FOLD CROSS-VALIDATION 
heartAgeDataHypertension.train.split<-split_data(heartAgeDataHypertension.train,props=c(0.7,0.3))
heartAgeDataHypertension.train.fold1<-heartAgeDataHypertension.train.split$"1"
heartAgeDataHypertension.train.fold2<-heartAgeDataHypertension.train.split$"2"

num_true<-length(which(heartAgeDataHypertension.train.fold1$heartAgeDataHypertension %in% "TRUE"))
num_false<-2*num_true


#TRAIN A DECISION TREE ON SURVEY DATA 
tree.survey.heartAgeDataHypertension=randomForest(formula('heartAgeDataHypertension~
                                     vigorous_act            +
                                     activity1_intensity     +
                                     activity1_option        +
                                     activity1_time          +
                                     activity1_type          +
                                     phys_activity 
                                     '),data=heartAgeDataHypertension.train.fold1,importance=TRUE,na.action=na.omit,strata=heartAgeDataHypertension.train.fold1$heartAgeDataHypertension,sampsize=c("TRUE"=num_true,"FALSE"=num_false))
par(mfrow=c(1,1))
#plot(tree.survey.heartAgeDataHypertension)
#text(tree.survey.heartAgeDataHypertension,pretty=0)

#tree.survey.pred=predict(tree.survey.heartAgeDataHypertension,heartAgeDataHypertension.train.fold2,type="class")
tree.survey.pred=predict(tree.survey.heartAgeDataHypertension,heartAgeDataHypertension.train.fold2,n.trees=1000)
print(table(tree.survey.pred,heartAgeDataHypertension.train.fold2$heartAgeDataHypertension))
#plot(heartAgeDataHypertension.train.fold2$heartAgeDataHypertension,tree.survey.pred)
#cor(heartAgeDataHypertension.train.fold2$heartAgeDataHypertension,tree.survey.pred,use="complete.obs")
