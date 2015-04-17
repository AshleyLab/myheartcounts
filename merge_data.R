library(dplyr)


heart.age <- read.table("../../data/tables/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv",header=T,as.is=T,sep="\t")
risk <- read.table("../../data/tables/cardiovascular-risk_factors-v1.tsv",header=T,as.is=T,sep="\t")
satisfied <- read.table("../../data/tables/cardiovascular-satisfied-v1.tsv",header=T,as.is=T,sep="\t")
sixmin <- read.table("../../data/tables/cardiovascular-6MinuteWalkTest-v2_withSteps.tsv",header=T,as.is=T,sep="\t")
quiz <- read.table("../../data/tables/cardiovascular-par-q quiz-v1.tsv",header=T,as.is=T,sep="\t")
day1 <- read.table("../../data/tables/cardiovascular-day_one-v1.tsv",header=T,as.is=T,sep="\t")
diet <- read.table("../../data/tables/cardiovascular-Diet_survey_cardio-v1.tsv",header=T,as.is=T,sep="\t")

### HEARTAGE CLEANING #############################################################################

heart.age$age = as.numeric(difftime(Sys.Date(),strptime(heart.age$heartAgeDataAge,"%Y-%m-%d"), units="weeks"))/52
heart.age$heartAgeDataGender[!heart.age$heartAgeDataGender%in%c("[HKBiologicalSexMale]", "[HKBiologicalSexFemale]")] = NA

heart.age$heartAgeDataLdl <- as.numeric(heart.age$heartAgeDataLdl)
heart.age$heartAgeDataHdl <- as.numeric(heart.age$heartAgeDataHdl)

# set outliers to null
heart.age[heart.age$heartAgeDataTotalCholesterol<50 | heart.age$heartAgeDataTotalCholesterol>400,"heartAgeDataTotalCholesterol"] <- NA
heart.age[!is.na(heart.age$age) & (heart.age$age<18 | heart.age$age>120),"age"] <- NA
heart.age[!is.na(heart.age$heartAgeDataHdl) &  (as.numeric(heart.age$heartAgeDataHdl)<10 | as.numeric(heart.age$heartAgeDataHdl)>120),"heartAgeDataHdl"] <- NA
heart.age[!is.na(heart.age$heartAgeDataLdl) &  (as.numeric(heart.age$heartAgeDataLdl)<10 | as.numeric(heart.age$heartAgeDataLdl)>360),"heartAgeDataLdl"] <- NA
heart.age[!is.na(heart.age$heartAgeDataBloodGlucose) &  (heart.age$heartAgeDataBloodGlucose<1 | heart.age$heartAgeDataBloodGlucose>500),"heartAgeDataBloodGlucose"] <- NA
heart.age[heart.age$bloodPressureInstruction<60 | heart.age$bloodPressureInstruction>220,"bloodPressureInstruction"] <- NA
heart.age[!is.na(heart.age$heartAgeDataSystolicBloodPressure) & (heart.age$heartAgeDataSystolicBloodPressure<50 | heart.age$heartAgeDataSystolicBloodPressure>220),"heartAgeDataSystolicBloodPressure"] <- NA
heart.age[!is.na(heart.age$bloodPressureInstruction) & (heart.age$bloodPressureInstruction<60 | heart.age$bloodPressureInstruction>220),"heartAgeDataSystolicBloodPressure"] <- NA
heart.age$age <-  round((as.numeric(difftime(Sys.Date(), strptime(heart.age$heartAgeDataAge, "%Y-%m-%d"), units="days"))/365.15),2)
heart.age$mpb <-  round(heart.age$heartAgeDataSystolicBloodPressure + 1/3*(heart.age$bloodPressureInstruction -  heart.age$heartAgeDataSystolicBloodPressure),2)


# Filter gender

# take first value for duplicate healthcodes


# write output
