## Let's build the regression model:

# Diet, Satisfaction, HeartAge, etc. 

cv_health = read.table("../2015-04-12/cardiovascular-risk_factors-v1.tsv", sep="\t", head=T)

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

summary(lm(hasDisease ~ age + gender + pActive, data=dsams_collapse))

summary(lm(satisfaction ~ age + gender + pActive, data=dsams_collapse))



## Lets do a step here:
step(baseDisease.lm, scope=fullDisease.lm, direction="forward")

