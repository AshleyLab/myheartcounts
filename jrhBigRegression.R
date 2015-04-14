## Let's build the regression model:

require(plyr)
require(MASS)

# Diet, Satisfaction, HeartAge, etc. 

cv_health = read.table("../2015-04-12/cardiovascular-risk_factors-v1.tsv", sep="\t", head=T)
zip_codes = read.table("zips_expanded.txt", sep="\t")
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

# Merge everything - wow lol
diet_satisfy <- merge(dietTable, satisfiedTable, by="healthCode")
diet_satisfy_state <- merge(diet_satisfy, zip_codes, by.x="zip", by.y="prefix")
diet_sat_age = merge(diet_satisfy_state, hearttable, by="healthCode")
diet_sat_age_motion = merge(diet_sat_age, indiv, by="healthCode")
diet_sat_age_motion_six = merge(diet_sat_age_motion, sixmin, by="healthCode")
diet_sat_age_motion_six$pActive = diet_sat_age_motion_six$pWalk + diet_sat_age_motion_six$pRun + diet_sat_age_motion_six$pCycle
lots_of_merge = merge(diet_sat_age_motion_six, cv_health, by="healthCode")
# do they have heart disease?
lots_of_merge$hasDisease = lots_of_merge$heart_disease != "[10]" 
lots_of_merge$age = as.numeric(difftime("2015-04-08",strptime(lots_of_merge$heartAgeDataAge,"%Y-%m-%d"), units="weeks"))/52

dsams_collapse = ddply(lots_of_merge, .(healthCode), summarize, sys.bp=mean(bloodPressureInstruction), ethnicity = heartAgeDataGender[1], gender = heartAgeDataGender[1], hdl = mean(heartAgeDataHdl), ldl=mean(heartAgeDataLdl),chol=mean(heartAgeDataTotalCholesterol), age = mean(age), diabetes=heartAgeDataDiabetes[1], vegetable = mean(vegetable,na.rm=T), fruit=mean(fruit,na.rm=T), smokingHistory=smokingHistory[1], pActive=mean(pActive), sugar_drinks = mean(sugar_drinks, na.rm=T), satisfaction = mean(satisfiedwith_life, na.rm=T), worthwhile = mean(feel_worthwhile1), happy=mean(feel_worthwhile2,na.rm=T), worry = mean(feel_worthwhile3,na.rm=T), depress=mean(feel_worthwhile4, na.rm=T), zip=zip[1], state=state[1], numberOfSteps = mean(numberOfSteps, na.rm=T), distance = mean(distance, na.rm=T), hasDisease=max(hasDisease))

write.table(dsams_collapse, file="dsams_collapse.tsv", sep="\t", row.names=F)

## Filters:

# Filter age to reasonable values
dsams_collapse$age[dsams_collapse$age > 120]= NA
dsams_collapse$age[dsams_collapse$age < 18] = NA

# Filter BP
dsams_collapse$sys.bp[dsams_collapse$sys.bp>220] = NA
dsams_collapse$sys.bp[dsams_collapse$sys.bp<60] = NA

# Filter chol
dsams_collapse$chol[dsams_collapse$chol>400] = NA
dsams_collapse$chol[dsams_collapse$chol<100] = NA

# Filter LDL
dsams_collapse$ldl[dsams_collapse$ldl<10] = NA
dsams_collapse$ldl[dsams_collapse$ldl>360] = NA

# Filter Hdl
dsams_collapse$hdl[dsams_collapse$hdl<10] = NA
dsams_collapse$hdl[dsams_collapse$hdl>120] = NA

# Filter gender
dsams_collapse$gender[!dsams_collapse$gender%in%c("[\"HKBiologicalSexMale\"]", "[\"HKBiologicalSexFemale\"]")] = NA

summary(baseDisease.lm <- lm(hasDisease ~ age+gender, data=dsams_collapse))
summary(fullDisease.lm <- lm(hasDisease ~ age+gender+sys.bp + hdl + ldl + chol + diabetes + vegetable + fruit + smokingHistory + pActive + sugar_drinks + satisfaction + worthwhile + worry + depress + numberOfSteps,  data=dsams_collapse))

# Need to collapse to complete records for AIC step
dsams_collapse_full = na.omit(dsams_collapse)

summary(baseDisease_full.lm <- lm(hasDisease ~ age+gender, data=dsams_collapse_full))
summary(fullDisease_full.lm <- lm(hasDisease ~ age+gender+sys.bp + hdl + ldl + chol + diabetes + vegetable + fruit + smokingHistory + pActive + sugar_drinks + satisfaction + worthwhile + worry + depress + numberOfSteps,  data=dsams_collapse_full))

## Lets do a step here:
step(fullDisease_full.lm,baseDisease_full.lm)

summary(backwardsAIC.lm <- lm(formula = hasDisease ~ age + gender + sys.bp + chol + pActive + satisfaction + worry + depress + numberOfSteps, data = dsams_collapse_full))

forwardsAIC.lm = step(baseDisease_full.lm, fullDisease_full.lm, direction="forward")


