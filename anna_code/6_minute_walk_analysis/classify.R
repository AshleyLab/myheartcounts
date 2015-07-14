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
merged$heart_disease<-factor(merged$heart_disease)
merged$family_history<-factor(merged$family_history)
merged$sodium<-factor(merged$sodium)
merged$phone_on_user<-factor(merged$phone_on_user)


#TRAINING DATA (Age/Sex known)
sex.train<-subset(merged,merged$Sex!="NA")
sex.test<-subset(merged,merged$Sex=="NA")
age.train<-subset(merged,merged$Age!="NA")
age.test<-subset(merged,merged$Age=="NA")

#RANDOMLY SPLIT TRAINING DATA FOR 2-FOLD CROSS-VALIDATION 
sex.train.split<-split_data(sex.train,props=c(0.7,0.3))
age.train.split<-split_data(age.train,props=c(0.7,0.3))

sex.train.fold1<-sex.train.split$"1"
sex.train.fold2<-sex.train.split$"2"

age.train.fold1<-age.train.split$"1"
age.train.fold2<-age.train.split$"2"

#TRAIN A DECISION TREE ON ACCELERATION DATA FOLD 1 (SEX)
num_females<-length(which(sex.train.fold1$Sex %in% "Female"))
num_other<-length(which(sex.train.fold1$Sex %in% "Other"))
num_males <-2*num_females

tree.sex=randomForest(Sex~wx1+wx2+wx3+wx4+wx5+wx6+wx7+wx8+wx9+wx10+
                wy1+wy2+wy3+wy4+wy5+wy6+wy7+wy8+wy9+wy10+
                wz1+wz2+wz3+wz4+wz5+wz6+wz7+wz8+wz9+wz10,sex.train.fold1,importance=TRUE,na.action=na.roughfix,strata=sex.train.fold1$Sex,sampsize=c(Male=num_males,Female=num_females,Other=num_other),cutoff=c(0.3,0.6,0.1))
#plot(tree.sex)
#text(tree.sex,pretty=0)
tree.pred.sex=predict(tree.sex,sex.train.fold2,type="class")
print(table(tree.pred.sex,sex.train.fold2$Sex))
#TRY PRUNING THE TREE (DIDN'T HELP)
#cv.sex=cv.tree(tree.sex,FUN=prune.misclass)
#par(mfrow=c(1,2))
#plot(cv.sex$size,cv.sex$dev,type="b")
#plot(cv.sex$k,cv.sex$dev,type="b")

#AGE 


tree.age=randomForest(Age~wx1+wx2+wx3+wx4+wx5+wx6+wx7+wx8+wx9+wx10+
                wy1+wy2+wy3+wy4+wy5+wy6+wy7+wy8+wy9+wy10+
                wz1+wz2+wz3+wz4+wz5+wz6+wz7+wz8+wz9+wz10,age.train.fold1,importance=TRUE,na.action=na.roughfix)
#tree.age=gbm(Age~wx1+wx2+wx3+wx4+wx5+wx6+wx7+wx8+wx9+wx10+wy1+wy2+wy3+wy4+wy5+wy6+wy7+wy8+wy9+wy10+wz1+wz2+wz3+wz4+wz5+wz6+wz7+wz8+wz9+wz10,data=age.train.fold1,distribution="gaussian", n.trees=5000,interaction.depth=5)
par(mfrow=c(1,1))
#plot(tree.age)
#text(tree.age,pretty=0)
#tree.pred=predict(tree.age,age.train.fold2,n.trees=500)
tree.pred.age=predict(tree.age,age.train.fold2)
table(tree.pred.age,age.train.fold2$Age)
plot(age.train.fold2$Age,tree.pred.age)
print(cor(age.train.fold2$Age,tree.pred.age,use="complete.obs"))
