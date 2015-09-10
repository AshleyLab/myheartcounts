## Let's build the regression model:

require(plyr)
require(MASS)

# Diet, Satisfaction, HeartAge, etc. 
setwd("/Users/Julian/Documents/AshleyLab/MHealth/2015-04-12")
cv_health = read.table("../2015-04-12/cardiovascular-risk_factors-v1.tsv", sep="\t", head=T)
zip_codes = read.table("../zips_expanded.txt", sep="\t")
names(zip_codes) = c("prefix", "state_code", "state")
satisfiedTable = read.table("/Users/Julian/Documents/AshleyLab/MHealth/2015-04-12/cardiovascular-satisfied-v1.tsv", head=T, sep="\t")
dietTable = read.table("/Users/Julian/Documents/AshleyLab/MHealth/2015-04-12/cardiovascular-Diet_survey_cardio-v1.tsv", head=T, sep="\t")
hearttable = read.table("/Users/Julian/Documents/AshleyLab/MHealth/2015-04-12/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv", head=T, sep="\t")
sixmin = read.table("../2015-04-12/6minWalk_healthCode_steps.tsv", head=T, sep="\t")



# Individual motion data
indiv_all = read.table("/Users/Julian/Documents/AshleyLab/MHealth/2015-04-12/indMotion0412.txt", sep="\t", head=T)

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

lots_of_merge$cholDrug = grepl("1", lots_of_merge$medications_to_treat)
lots_of_merge$bpDrug = grepl("2", lots_of_merge$medications_to_treat)

cv_health$cholDrug = grepl("1", cv_health$medications_to_treat)
cv_health$bpDrug = grepl("2", cv_health$medications_to_treat)
cv_health$hasDisease = cv_health$heart_disease != "[10]" & cv_health$heart_disease != "[]"
cv_health$onDrug = cv_health$medications_to_treat != "[4]" & cv_health$medications_to_treat !="[]"

cv_health_collapse = ddply(cv_health, .(healthCode), summarize, hasDisease = max(hasDisease), onDrug=max(onDrug))

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

dsams_collapse = ddply(lots_of_merge, .(healthCode), summarize, sys.bp=mean(bloodPressureInstruction, na.rm=T), ethnicity = heartAgeDataEthnicity[1], gender = heartAgeDataGender[1], hdl = mean(heartAgeDataHdl,na.rm=T), ldl=mean(heartAgeDataLdl,na.rm=T),chol=mean(heartAgeDataTotalCholesterol,na.rm=T), age = mean(age), diabetes=heartAgeDataDiabetes[1], vegetable = mean(vegetable,na.rm=T), fruit=mean(fruit,na.rm=T), smokingHistory=smokingHistory[1], pActive=mean(pActive), sugar_drinks = mean(sugar_drinks, na.rm=T), satisfaction = mean(satisfiedwith_life, na.rm=T), worthwhile = mean(feel_worthwhile1,na.rm=T), happy=mean(feel_worthwhile2,na.rm=T), worry = mean(feel_worthwhile3,na.rm=T), depress=mean(feel_worthwhile4, na.rm=T), zip=zip[1], state=state[1], numberOfSteps = mean(numberOfSteps, na.rm=T), distance = mean(distance, na.rm=T), cholDrug = max(cholDrug, na.rm=T), bpDrug = max(bpDrug, na.rm=T), hasDisease=max(hasDisease, na.rm=T))
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
write.table(dsams_collapse, file="dsams_collapse_0414_2.tsv", sep="\t", row.names=F)


summary(baseDisease.lm <- lm(hasDisease ~ age*gender, data=dsams_collapse))
summary(fullDisease.lm <- lm(hasDisease ~ age*gender+sys.bp + hdl + chol + diabetes + vegetable + fruit + smokingHistory + pActive + sugar_drinks + satisfaction + worthwhile + worry + depress + numberOfSteps,  data=dsams_collapse))

# Need to collapse to complete records for AIC step
dsams_collapse_full = na.omit(dsams_collapse)
dsams_collapse_full$smokingHistory=as.numeric(dsams_collapse_full$smokingHistory)
dsams_collapse_full$diabetes=as.numeric(dsams_collapse_full$diabetes)

dsams_collapse_num = dsams_collapse[,!colnames(dsams_collapse)%in%c("state","zip","gender","ethnicity", "healthCode")]
dsams_corr = cor(dsams_collapse_num, use="pairwise.complete")

dsams_collapse$ethnicity2 = dsams_collapse$ethnicity
dsams_collapse$ethnicity2[dsams_collapse$ethnicity2%in%c("[Black]", "[American Indian]", "[Alaska Native]", "[Pacific Islander]")] = "[Other]"
dsams_collapse$ethnicity2[dsams_collapse$ethnicity2%in%c("[]", "[I prefer not to indicate an ethnicity]")] = NA
# First thing - collapse ethnicity to White, Asian, Black, Hispanic, Other

# Base model: Always has age, sex, age:sex , and ethnicity
# Test each other variable univariately (with base model) against each one.
# Correlated variables: greater than 0.5 correlation coefficient
# Add only most univariately associated of the potential correlated variables
# Then, add all these variables to the "full scope" model
# Run stepwise AIC "both" model selection against the data

# Run it with the steps included and without the six minute walk stuff included

## Correlated variables:
# 1. LDL + Total Cholesterol
# 2. Worthwhile, happy, satisfaction
# 3. Worry, depressed
# 4. Number of steps, distance

## Has Disease dependent variable
for (g in c("hasDisease", "satisfaction")) {
  for (q in names(dsams_collapse)) {
    if (g=="hasDisease") {
      print(paste(g,"_",q,".lm <- glm(" ,g, " ~ ",q," + age:gender + ethnicity, family='binomial', data=dsams_collapse)", sep=""))
    } else {
      print(paste(g,"_",q,".lm <- lm(" ,g, " ~ ",q," + age:gender + ethnicity, data=dsams_collapse)", sep=""))
      
    }  
      
    print(paste("summary(",g,"_",q,".lm)",sep=""))
  }
}

## Lets run all the linear models:

hasDisease_sys.bp.lm <- glm(hasDisease ~ sys.bp + age*gender + ethnicity2, family='binomial', data=dsams_collapse)

hasDisease_sys.bp.lm <- glm(hasDisease ~ sys.bp*bpDrug+ age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_sys.bp.lm)

hasDisease_ethnicity2.lm <- glm(hasDisease ~ ethnicity2 + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_ethnicity2.lm)
hasDisease_gender.lm <- glm(hasDisease ~ gender + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_gender.lm)
hasDisease_hdl.lm <- glm(hasDisease ~ hdl + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_hdl.lm)
hasDisease_ldl.lm <- glm(hasDisease ~ ldl*cholDrug + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_ldl.lm)
hasDisease_chol.lm <- glm(hasDisease ~ age*gender + cholDrug*chol +ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_chol.lm)
hasDisease_age.lm <- glm(hasDisease ~ age + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_age.lm)
hasDisease_diabetes.lm <- glm(hasDisease ~ diabetes + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_diabetes.lm)
hasDisease_vegetable.lm <- glm(hasDisease ~ vegetable + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_vegetable.lm)
hasDisease_fruit.lm <- glm(hasDisease ~ fruit + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_fruit.lm)
hasDisease_smokingHistory.lm <- glm(hasDisease ~ smokingHistory + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_smokingHistory.lm)
hasDisease_pActive.lm <- glm(hasDisease ~ pActive + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_pActive.lm)
hasDisease_sugar_drinks.lm <- glm(hasDisease ~ sugar_drinks + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_sugar_drinks.lm)
hasDisease_satisfaction.lm <- glm(hasDisease ~ satisfaction + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_satisfaction.lm)
hasDisease_worthwhile.lm <- glm(hasDisease ~ worthwhile + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_worthwhile.lm)
hasDisease_happy.lm <- glm(hasDisease ~ happy + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_happy.lm)
hasDisease_worry.lm <- glm(hasDisease ~ worry + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_worry.lm)
hasDisease_depress.lm <- glm(hasDisease ~ depress + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_depress.lm)
hasDisease_zip.lm <- glm(hasDisease ~ zip + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_zip.lm)
hasDisease_state.lm <- glm(hasDisease ~ state + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_state.lm)
hasDisease_numberOfSteps.lm <- glm(hasDisease ~ numberOfSteps + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_numberOfSteps.lm)
hasDisease_distance.lm <- glm(hasDisease ~ distance + age*gender + ethnicity2, family='binomial', data=dsams_collapse)
summary(hasDisease_distance.lm)


### Let's change into the satisfaction part here

satisfaction_sys.bp.lm <- lm(satisfaction ~ sys.bp*bpDrug + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_sys.bp.lm)
satisfaction_ethnicity2.lm <- lm(satisfaction ~ ethnicity2 + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_ethnicity2.lm)
satisfaction_gender.lm <- lm(satisfaction ~ gender + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_gender.lm)
satisfaction_hdl.lm <- lm(satisfaction ~ hdl + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_hdl.lm)
satisfaction_ldl.lm <- lm(satisfaction ~ ldl*cholDrug + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_ldl.lm)
satisfaction_chol.lm <- lm(satisfaction ~ chol*cholDrug + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_chol.lm)
satisfaction_age.lm <- lm(satisfaction ~ age + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_age.lm)
satisfaction_diabetes.lm <- lm(satisfaction ~ diabetes + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_diabetes.lm)
satisfaction_vegetable.lm <- lm(satisfaction ~ vegetable + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_vegetable.lm)
satisfaction_fruit.lm <- lm(satisfaction ~ fruit + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_fruit.lm)
satisfaction_smokingHistory.lm <- lm(satisfaction ~ smokingHistory + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_smokingHistory.lm)
satisfaction_pActive.lm <- lm(satisfaction ~ pActive*age + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_pActive.lm)
AIC(satisfaction_pActive.lm)
satisfaction_pActive_age.lm <- lm(satisfaction ~ pActive + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_pActive_age.lm)
AIC(satisfaction_pActive_age.lm)

satisfaction_sugar_drinks.lm <- lm(satisfaction ~ sugar_drinks + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_sugar_drinks.lm)
satisfaction_satisfaction.lm <- lm(satisfaction ~ satisfaction + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_satisfaction.lm)
satisfaction_worthwhile.lm <- lm(satisfaction ~ worthwhile + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_worthwhile.lm)
satisfaction_happy.lm <- lm(satisfaction ~ happy + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_happy.lm)
satisfaction_worry.lm <- lm(satisfaction ~ worry + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_worry.lm)
satisfaction_depress.lm <- lm(satisfaction ~ depress + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_depress.lm)
satisfaction_zip.lm <- lm(satisfaction ~ zip + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_zip.lm)
satisfaction_state.lm <- lm(satisfaction ~ state + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_state.lm)
satisfaction_numberOfSteps.lm <- lm(satisfaction ~ numberOfSteps*age + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_numberOfSteps.lm)
satisfaction_distance.lm <- lm(satisfaction ~ distance*age + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_distance.lm)
satisfaction_hasDisease.lm <- lm(satisfaction ~ hasDisease + age*gender + ethnicity2, data=dsams_collapse)
summary(satisfaction_hasDisease.lm)





### Build multivariate models with base params and significant params
# exclude ldl
dsams_collapse_noldl = na.omit(dsams_collapse[,!colnames(dsams_collapse)%in%c("distance","numberOfSteps","ldl")])

baseDisease.lm = glm(hasDisease ~ age*gender + ethnicity2, data=dsams_collapse_noldl)
fullDisease.lm = glm(hasDisease ~ age*gender + ethnicity2 + chol*cholDrug + satisfaction + diabetes + pActive + depress, data=dsams_collapse_noldl)

disease_Step.lm = step(baseDisease.lm, list(lower=baseDisease.lm, upper=fullDisease.lm), direction="both")
summary(disease_Step.lm)
length(resid(disease_Step.lm))

### Build the multivariate 

dsams_collapse_satis = na.omit(dsams_collapse[c("satisfaction","age", "gender", "ethnicity2",  "sys.bp", "diabetes", "vegetable", "fruit", "smokingHistory", "pActive", "sugar_drinks", "numberOfSteps", "hasDisease", "distance", "bpDrug")])
baseSatisfy.lm = lm(satisfaction~ age*gender + ethnicity2, data=dsams_collapse_satis)
fullSatisfy.lm = lm(satisfaction~ age*gender + ethnicity2 + sys.bp*bpDrug + diabetes + vegetable + fruit + smokingHistory + pActive + sugar_drinks + hasDisease+ numberOfSteps + distance, data=dsams_collapse_satis)
satisfy_step.lm = step(baseSatisfy.lm, scope=list(upper=fullSatisfy.lm, lower=baseSatisfy.lm), direction="both")
summary(satisfy_step.lm)
length(resid(satisfy_step.lm))


dsams_collapse_nowalk = na.omit(dsams_collapse[c("satisfaction","age", "gender", "ethnicity2",  "sys.bp", "diabetes", "vegetable", "fruit", "smokingHistory", "pActive", "sugar_drinks",  "hasDisease", "bpDrug")])

baseSatisfy_n.lm = lm(satisfaction~ age*gender + ethnicity2, data=dsams_collapse_nowalk)
fullSatisfy_n.lm = lm(satisfaction~ age*gender + ethnicity2 + sys.bp*bpDrug + diabetes + vegetable + fruit + smokingHistory + pActive + sugar_drinks + hasDisease, data=dsams_collapse_nowalk)
satisfy_step_n.lm = step(baseSatisfy_n.lm, scope=list(upper=fullSatisfy_n.lm, lower=baseSatisfy_n.lm), direction="both")
summary(satisfy_step_n.lm)
length(resid(satisfy_step_n.lm))

satisfy_user = aggregate(satisfiedTable$satisfiedwith_life,by=list(satisfiedTable$healthCode), mean)
median(satisfy_user$x, na.rm=T)

unique_state = unique(data.frame(healthCode = diet_satisfy_state$healthCode, state=diet_satisfy_state$state))
num_inds = data.frame(table(unique_state$healthCode))
u_state_n = merge(unique_state, num_inds, by.x="healthCode", by.y="Var1")
u_state_n$weight = 1/u_state_n$Freq
state_counts = aggregate(u_state_n$weight, list(u_state_n$state), sum)
names(state_counts) = c("state", "count")
state_counts = subset(state_counts, !state%in%c("Armed Forces Americas", "Armed Forces Europe", "Armed Forces Asia", "Virgin Islands", "Puerto Rico", "Armed Forces Pacific", "Guam"))
