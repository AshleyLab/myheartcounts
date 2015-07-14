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

#TRAINING DATA (Sex/Sex known)
Sex.train<-subset(merged,is.na(merged$Sex)==FALSE)
Sex.test<-subset(merged,is.na(merged$Sex))


#RANDOMLY SPLIT TRAINING DATA FOR 2-FOLD CROSS-VALIDATION 
Sex.train.split<-split_data(Sex.train)
Sex.train.fold1<-Sex.train.split$"1"
Sex.train.fold2<-Sex.train.split$"2"


#TRAIN A DECISION TREE ON SURVEY DATA 
tree.survey.Sex=randomForest(formula('Sex~
                                       bloodPressureInstruction+
                                       heartAgeDataBloodGlucose+
                                       heartAgeDataDiabetes    +
                                       heartAgeDataEthnicity   +
                                       heartAgeDataHdl+
                                       heartAgeDataHypertension+
                                       heartAgeDataLdl         +
                                       smokingHistory          +
                                       heartAgeDataSystolicBloodPressure+
                                       heartAgeDataTotalCholesterol      +
                                       patientWeightPoints     +
                                       patientHeightInches     +
                                       atwork+
                                       moderate_act            +
                                       phys_activity           +
                                       sleep_diagnosis1        +
                                       sleep_time_ActivitySleep+
                                       sleep_time1             +
                                       vigorous_act            +
                                       work                    +
                                       activity1_intensity+
                                       activity1_option        +
                                       activity1_time          +
                                       activity1_type          +
                                       activity2_intensity+
                                       activity2_option        +
                                       activity2_time          +
                                       activity2_type          +
                                       phone_on_user+
                                       sleep_time_DailyCheck   +
                                       fish                    +
                                       fruit                   +
                                       grains+
                                       sodium                  +
                                       sugar_drinks            +
                                       vegetable               +
                                       chestPain+
                                       chestPainInLastMonth    +
                                       dizziness               +
                                       heartCondition          +
                                       jointProblem+
                                       physicallyCapable       +
                                       prescriptionDrugs       +
                                       family_history          +
                                       heart_disease+
                                       medications_to_treat    +
                                       vascular                +
                                       feel_worthwhile1        +
                                       feel_worthwhile2+
                                       feel_worthwhile3        +
                                       feel_worthwhile4        +
                                       riskfactors1            +
                                       riskfactors2+
                                       riskfactors3            +
                                       riskfactors4            +
                                       satisfiedwith_life      +
                                       zip'),data=Sex.train.fold1,importance=TRUE,na.action=na.tree.replace)
browser() 
#par(mfrow=c(1,1))rt
#plot(tree.survey.Sex)
#text(tree.survey.Sex,pretty=0)

#tree.survey.pred=predict(tree.survey.Sex,Sex.train.fold2,type="class")
tree.survey.pred=predict(tree.survey.Sex,Sex.train.fold2,n.trees=500)
table(tree.survey.pred,Sex.train.fold2$Sex)
plot(Sex.train.fold2$Sex,tree.survey.pred)
cor(Sex.train.fold2$Sex,tree.survey.pred,use="complete.obs")
