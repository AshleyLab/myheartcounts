## Let's build the regression model:

require(plyr)
require(MASS)

# Diet, Satisfaction, HeartAge, etc. 

cv_health = read.table("../2015-04-12/cardiovascular-risk_factors-v1.tsv", sep="\t", head=T)
zip_codes = read.table("../zips_expanded.txt", sep="\t")
names(zip_codes) = c("prefix", "state_code", "state")
satisfiedTable = read.table("/Users/Julian/Documents/AshleyLab/MHealth/2015-04-12/cardiovascular-satisfied-v1.tsv", head=T, sep="\t")
dietTable = read.table("/Users/Julian/Documents/AshleyLab/MHealth/2015-04-12/cardiovascular-Diet_survey_cardio-v1.tsv", head=T, sep="\t")
hearttable = read.table("/Users/Julian/Documents/AshleyLab/MHealth/2015-04-12/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv", head=T, sep="\t")


# Individual motion data
indiv_all = read.table("/Users/Julian/Documents/AshleyLab/MHealth/2015-04-12/indMotion0412.txt", sep="\t", head=T)

# six minute data
sixmin = read.table("../2015-04-12/6minWalk_healthCode_steps.tsv", head=T, sep="\t")

# Remove people with less than 12 hours of data:
indiv = subset(indiv_all, SecTotal > 3600*12)

indiv$pWalk = indiv$SecWalking/indiv$SecTotal
indiv$pStat = indiv$SecStationary/indiv$SecTotal
indiv$pRun = indiv$SecRunning/indiv$SecTotal
indiv$pCycle = indiv$SecCycling/indiv$SecTotal
indiv$pAuto = indiv$SecAutomotive/indiv$SecTotal

# Merge everything - wow lol
diet_satisfy <- merge(dietTable, satisfiedTable, by="healthCode", all=T)
diet_satisfy_state <- merge(diet_satisfy, zip_codes, by.x="zip", by.y="prefix", all=T)
diet_sat_age = merge(diet_satisfy_state, hearttable, by="healthCode", all.y=T)
diet_sat_age_motion = merge(diet_sat_age, indiv, by="healthCode", all.x=T)
diet_sat_age_motion_six = merge(diet_sat_age_motion, sixmin, by="healthCode", all.x=T)
diet_sat_age_motion_six$pActive = diet_sat_age_motion_six$pWalk + diet_sat_age_motion_six$pRun + diet_sat_age_motion_six$pCycle
lots_of_merge = merge(diet_sat_age_motion_six, cv_health, by="healthCode", all.x=T)
# do they have heart disease?
lots_of_merge$hasDisease = lots_of_merge$heart_disease != "[10]" & lots_of_merge$heart_disease != "[]"
lots_of_merge$hasDisease[lots_of_merge$heart_disease == "[]"] = NA
lots_of_merge$age = as.numeric(difftime("2015-04-08",strptime(lots_of_merge$heartAgeDataAge,"%Y-%m-%d"), units="weeks"))/52

# Filter age to reasonable values
lots_of_merge$age[lots_of_merge$age > 120]= NA
lots_of_merge$age[lots_of_merge$age < 18] = NA

# Filter BP
lots_of_merge$bloodPressureInstruction[lots_of_merge$bloodPressureInstruction>220] = NA
lots_of_merge$bloodPressureInstruction[lots_of_merge$bloodPressureInstruction<60] = NA

# Filter chol
lots_of_merge$heartAgeDataTotalCholesterol[lots_of_merge$heartAgeDataTotalCholesterol>400] = NA
lots_of_merge$heartAgeDataTotalCholesterol[lots_of_merge$heartAgeDataTotalCholesterol<50] = NA

# Filter LDL
lots_of_merge$heartAgeDataLdl[lots_of_merge$heartAgeDataLdl<10] = NA
lots_of_merge$heartAgeDataLdl[lots_of_merge$heartAgeDataLdl>360] = NA

# Filter Hdl
lots_of_merge$heartAgeDataHdl[lots_of_merge$heartAgeDataHdl<10] = NA
lots_of_merge$heartAgeDataHdl[lots_of_merge$heartAgeDataHdl>120] = NA

# Filter gender
lots_of_merge$heartAgeDataGender[!lots_of_merge$heartAgeDataGender%in%c("[HKBiologicalSexMale]", "[HKBiologicalSexFemale]")] = NA

dsams_collapse = ddply(lots_of_merge, .(healthCode), summarize, sys.bp=mean(bloodPressureInstruction, na.rm=T), ethnicity = heartAgeDataEthnicity[1], gender = heartAgeDataGender[1], hdl = mean(heartAgeDataHdl,na.rm=T), ldl=mean(heartAgeDataLdl,na.rm=T),chol=mean(heartAgeDataTotalCholesterol,na.rm=T), age = mean(age), diabetes=heartAgeDataDiabetes[1], vegetable = mean(vegetable,na.rm=T), fruit=mean(fruit,na.rm=T), smokingHistory=smokingHistory[1], pActive=mean(pActive), sugar_drinks = mean(sugar_drinks, na.rm=T), satisfaction = mean(satisfiedwith_life, na.rm=T), worthwhile = mean(feel_worthwhile1,na.rm=T), happy=mean(feel_worthwhile2,na.rm=T), worry = mean(feel_worthwhile3,na.rm=T), depress=mean(feel_worthwhile4, na.rm=T), zip=zip[1], state=state[1], numberOfSteps = mean(numberOfSteps, na.rm=T), distance = mean(distance, na.rm=T), hasDisease=max(hasDisease, na.rm=T))
dsams_collapse$hasDisease[dsams_collapse$hasDisease=="-Inf"] = NA

# Missing sleep

## Filters:

# Filter age to reasonable values
dsams_collapse$age[dsams_collapse$age > 120]= NA
dsams_collapse$age[dsams_collapse$age < 18] = NA

# Filter BP
dsams_collapse$sys.bp[dsams_collapse$sys.bp>220] = NA
dsams_collapse$sys.bp[dsams_collapse$sys.bp<60] = NA

# Filter chol
dsams_collapse$chol[dsams_collapse$chol>400] = NA
dsams_collapse$chol[dsams_collapse$chol<50] = NA

# Filter LDL
dsams_collapse$ldl[dsams_collapse$ldl<10] = NA
dsams_collapse$ldl[dsams_collapse$ldl>360] = NA

# Filter Hdl
dsams_collapse$hdl[dsams_collapse$hdl<10] = NA
dsams_collapse$hdl[dsams_collapse$hdl>120] = NA

# Filter gender
dsams_collapse$gender[!dsams_collapse$gender%in%c("[HKBiologicalSexMale]", "[HKBiologicalSexFemale]")] = NA
write.table(dsams_collapse, file="dsams_collapse_0414.tsv", sep="\t", row.names=F)


summary(baseDisease.lm <- lm(hasDisease ~ age*gender, data=dsams_collapse))
summary(fullDisease.lm <- lm(hasDisease ~ age*gender+sys.bp + hdl + chol + diabetes + vegetable + fruit + smokingHistory + pActive + sugar_drinks + satisfaction + worthwhile + worry + depress + numberOfSteps,  data=dsams_collapse))

# Need to collapse to complete records for AIC step
dsams_collapse_full = na.omit(dsams_collapse)

summary(glm(hasDisease~ age + gender + ldl, family="binomial",data=dsams_collapse))

summary(baseDisease_full.lm <- glm(hasDisease ~ age:gender + age + gender, data=dsams_collapse_full, family="binomial"))
summary(fullDisease_full.lm <- glm(hasDisease ~ age*gender+sys.bp + hdl + ldl + age*chol + diabetes + vegetable + fruit + smokingHistory + pActive + sugar_drinks + happy+satisfaction + worthwhile + worry + depress + numberOfSteps, family="binomial", data=dsams_collapse_full))

# First thing - collapse ethnicity to White, Asian, Black, Hispanic, Other

# Base model: Always has age, sex, age:sex , and ethnicity interaction
# Test each other variable univariately (with base model) against each one.
# Correlated variables: greater than 0.5 correlation coefficient
# Add only most univariately associated of the potential correlated variables
# Then, add all these variables to the "full scope" model
# Run stepwise AIC "both" model selection against the data

# Run it with the steps included and without the six minute walk stuff included


## Lets do a step here:
backwardsDiseaseAIC.lm= step(fullDisease_full.lm, scope=c(lower=baseDisease_full.lm, upper=fullDisease_full.lm))

summary(backwardsDiseaseAIC.lm)
summary(backwardsDiseaseAIC_all.lm <- lm(backwardsDiseaseAIC.lm, data = dsams_collapse))

forwardsAIC.lm = step(baseDisease_full.lm,scope=list(upper=fullDisease_full.lm,lower=~1))

summary(forwardsAIC.lm)




summary(baseSat_full.lm <- lm(satisfaction ~ age+gender, data=dsams_collapse_full))
summary(fullSat_full.lm <- lm(satisfaction ~ age+gender+sys.bp + hdl + ldl + chol + diabetes + vegetable + fruit + smokingHistory + pActive + sugar_drinks + numberOfSteps, data=dsams_collapse_full))

forStepAIC.lm = step(baseSat_full.lm, scope=list(lower=~1, upper=fullSat_full.lm))
summary(forStepAIC.lm)

backStepAIC.lm = step(fullSat_full.lm, scope=list(lower=~1, upper=fullSat_full.lm))
summary(backStepAIC.lm)
