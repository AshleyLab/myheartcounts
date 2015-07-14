library(tree)
library(data.table)
library(randomForest)
rm(list=ls())

source('split_data.R')

merged<-read.table('/home/anna/r_scripts/merged_acceleration_meta.txt')
merged<-as.data.frame(merged) #COERCE THE DATA TABLE TO A DATA FRAME 
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


#TRAINING DATA (Age/hdisease known)
hdisease.train<-subset(merged,is.na(merged$heartAgeDataHypertension)==FALSE)
hdisease.test<-subset(merged,is.na(merged$heartAgeDataHypertension))

#RANDOMLY SPLIT TRAINING DATA FOR 2-FOLD CROSS-VALIDATION 
hdisease.train.split<-split_data(hdisease.train)

hdisease.train.fold1<-hdisease.train.split$"1"
hdisease.train.fold2<-hdisease.train.split$"2"

#TRAIN A DECISION TREE ON ACCELERATION DATA FOLD 1 (hdisease)
tree.hdisease=randomForest(heartAgeDataHypertension~wx1+wx2+wx3+wx4+wx5+wx6+wx7+wx8+wx9+wx10+
                wy1+wy2+wy3+wy4+wy5+wy6+wy7+wy8+wy9+wy10+
                wz1+wz2+wz3+wz4+wz5+wz6+wz7+wz8+wz9+wz10+
                rx1+rx2+rx3+rx4+rx5+rx6+rx7+rx8+rx9+rx10+
                ry1+ry2+ry3+ry4+ry5+ry6+ry7+ry8+ry9+ry10+
                rz1+rz2+rz3+rz4+rz5+rz6+rz7+rz8+rz9+rz10,hdisease.train.fold1,importance=TRUE,na.action=na.omit)
#par(mfrow=c(1,1))
#plot(tree.hdisease)
#text(tree.hdisease,pretty=0)
tree.pred=predict(tree.hdisease,hdisease.train.fold2,type="class")
table(tree.pred,hdisease.train.fold2$heartAgeDataHypertension)
