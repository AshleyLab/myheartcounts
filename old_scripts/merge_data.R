### PREAMBLE ######################################################################################
library(dplyr)

### DATA ##########################################################################################

data.path <- "/home/common/myheart/data/tables/"

demographics <- read.table(paste0(data.path, "cardiovascular-NonIdentifiableDemographics-v1.tsv"), header=T,as.is=T,sep="\t")
heart.age <- read.table(paste0(data.path, "cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv"),header=T,as.is=T,sep="\t")
risk <- read.table(paste0(data.path,"cardiovascular-risk_factors-v1.tsv"),header=T,as.is=T,sep="\t")
satisfied <- read.table(paste0(data.path, "/cardiovascular-satisfied-v1.tsv"),header=T,as.is=T,sep="\t")
sixmin <- read.table(paste0(data.path, "cardiovascular-6MinuteWalkTest-v2_withSteps.tsv"),header=T,as.is=T,sep="\t")
quiz <- read.table(paste0(data.path, "cardiovascular-par-q quiz-v1.tsv"),header=T,as.is=T,sep="\t")
day1 <- read.table(paste0(data.path, "cardiovascular-day_one-v1.tsv"),header=T,as.is=T,sep="\t")
diet <- read.table(paste0(data.path, "cardiovascular-Diet_survey_cardio-v1.tsv"),header=T,as.is=T,sep="\t")
satisfied <- read.table(paste0(data.path, "cardiovascular-satisfied-v1.tsv"),header=T,as.is=T,sep="\t")

### HEARTAGE CLEANING #############################################################################
# heart age is only a subset of patients and has conflicting values for a single healthCode

# calc age
#heart.age$age = as.numeric(difftime(Sys.Date(),strptime(heart.age$heartAgeDataAge,"%Y-%m-%d"), units="weeks"))/52

# fix sex
heart.age$heartAgeDataGender[!heart.age$heartAgeDataGender%in%c("[HKBiologicalSexMale]", "[HKBiologicalSexFemale]")] = NA

# convert to numberic
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

# group sparse ethnicities
heart.age[heart.age$heartAgeDataEthnicity=="[]", "heartAgeDataEthnicity"] <- NA
heart.age[!is.na(heart.age$heartAgeDataEthnicity) & heart.age$heartAgeDataEthnicity=="[Alaska Native]", "heartAgeDataEthnicity"] <- "[American Indian]"
heart.age[!is.na(heart.age$heartAgeDataEthnicity) & heart.age$heartAgeDataEthnicity=="[I prefer not to indicate an ethnicity]", "heartAgeDataEthnicity"] <- "[Other]"

# calc age
heart.age$age <-  round((as.numeric(difftime(Sys.Date(), strptime(heart.age$heartAgeDataAge, "%Y-%m-%d"), units="days"))/365.15),2)

# calc mid bp
heart.age$mpb <-  round(heart.age$heartAgeDataSystolicBloodPressure + 1/3*(heart.age$bloodPressureInstruction -  heart.age$heartAgeDataSystolicBloodPressure),2)

# take first value for duplicate healthcodes
heart.age <- by(heart.age, heart.age$healthCode, function(x){x[1,]})
heart.age <- data.frame(rbindlist(heart.age))

# merge with risk
risk <- risk[!duplicated(risk$healthCode),]
heart.age <- merge(heart.age,risk,by="healthCode",all.x=T)

# define if taking medication
heart.age$cholDrug = grepl("1", heart.age$medications_to_treat)
heart.age$bpDrug = grepl("2", heart.age$medications_to_treat)

# define if has disease
heart.age$hasDisease <- heart.age$heart_disease != "[10]" & heart.age$heart_disease != "[]"
heart.age$hasDisease[heart.age$heart_disease == "[]"] = NA

# write output
