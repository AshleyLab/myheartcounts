source("merge_data.R")


### DATA
# table 1 age, ethn, geo, diab, ht, smok, cholest, fh, med
summarize_heartage <- function(x) {
    c(
      n=nrow(x), n.age = sum(!is.na(x$age)), m.age = mean(x$age,na.rm=T), s.age = sd(x$age,na.rm=T), 
      n.sbp = sum(!is.na(x$bloodPressureInstruction)), m.sbp = mean(x$bloodPressureInstruction,na.rm=T), s.sbp = sd(x$bloodPressureInstruction,na.rm=T), 
      n.dbp = sum(!is.na(x$heartAgeDataSystolicBloodPressure)), m.dbp = mean(x$heartAgeDataSystolicBloodPressure,na.rm=T), s.dbp = sd(x$heartAgeDataSystolicBloodPressure,na.rm=T),
      n.mbp = sum(!is.na(x$mpb)), m.mbp = mean(x$mpb,na.rm=T), s.mbp = sd(x$mpb,na.rm=T),
      n.chol = sum(!is.na(x$heartAgeDataTotalCholesterol)), m.chol = mean(x$heartAgeDataTotalCholesterol,na.rm=T), s.chol = sd(x$heartAgeDataTotalCholesterol,na.rm=T),
      n.hdl = sum(!is.na(x$heartAgeDataHdl)), m.hdl = mean(as.numeric(x$heartAgeDataHdl),na.rm=T), s.hdl = sd(as.numeric(x$heartAgeDataHdl),na.rm=T),
      n.ldl = sum(!is.na(x$heartAgeDataLdl)), m.ldl = mean(as.numeric(x$heartAgeDataLdl),na.rm=T), s.hdl = sd(as.numeric(x$heartAgeDataLdl),na.rm=T),
      n.glu = sum(!is.na(x$heartAgeDataBloodGlucose)), m.glu = mean(x$heartAgeDataBloodGlucose,na.rm=T), s.glu = sd(x$heartAgeDataBloodGlucose,na.rm=T),
      n.ht = sum(!is.na(x$heartAgeDataHypertension)), t.ht = sum(x$heartAgeDataHypertension==T,na.rm=T), f.ht = sum(x$heartAgeDataHypertension==F,na.rm=T),
      n.diab = sum(!is.na(x$heartAgeDataDiabetes)), t.diab = sum(x$heartAgeDataDiabetes==T,na.rm=T), f.diab = sum(x$heartAgeDataDiabetes==F,na.rm=T),
      n.smk = sum(!is.na(x$smokingHistory)), t.smk = sum(x$smokingHistory==T,na.rm=T), f.smk = sum(x$smokingHistory==F,na.rm=T),
      n.ethnicity = sum(!is.na(x$heartAgeDataEthnicity),na.rm=T), n.ethnicity.white = sum(x$heartAgeDataEthnicity == "[White]",na.rm=T), n.ethnicity.hispanic = sum(x$heartAgeDataEthnicity == "[Hispanic]",na.rm=T) ,n.ethnicity.asian = sum(x$heartAgeDataEthnicity == "[Asian]",na.rm=T) ,n.ethnicity.black = sum(x$heartAgeDataEthnicity == "[Black]",na.rm=T), n.ethnicity.other = sum(x$heartAgeDataEthnicity %in%  c("[Alaska Native]","[American Indian]", "[Other]", "[Pacific Islander]")),    
      n.heart.disease = sum(!is.na(x$hasDisease),na.rm=T), n.heart.disease.t = sum(x$hasDisease,na.rm=T), n.heart.disease.f = sum(!x$hasDisease,na.rm=T),
      n.chol.med = sum(!is.na(x$cholDrug),na.rm=T), n.chol.med.t = sum(x$cholDrug,na.rm=T), n.chol.med.f = sum(!x$cholDrug,na.rm=T),
      n.bp.med = sum(!is.na(x$bpDrug),na.rm=T), n.bp.med.t = sum(x$bpDrug,na.rm=T), n.bp.med.f = sum(!x$bpDrug,na.rm=T)
      )
    }


#heart.age.collapse = ddply(heart.age, .(healthCode), summarize, sys.bp=mean(bloodPressureInstruction, na.rm=T), ethnicity = heartAgeDataEthnicity[1], gender = heartAgeDataGender[1], hdl = mean(heartAgeDataHdl,na.rm=T), ldl=mean(heartAgeDataLdl,na.rm=T),chol=mean(heartAgeDataTotalCholesterol,na.rm=T), age = mean(age), diabetes=heartAgeDataDiabetes[1], vegetable = mean(vegetable,na.rm=T), fruit=mean(fruit,na.rm=T), smokingHistory=smokingHistory[1], pActive=mean(pActive), sugar_drinks = mean(sugar_drinks, na.rm=T), satisfaction = mean(satisfiedwith_life, na.rm=T), worthwhile = mean(feel_worthwhile1,na.rm=T), happy=mean(feel_worthwhile2,na.rm=T), worry = mean(feel_worthwhile3,na.rm=T), depress=mean(feel_worthwhile4, na.rm=T), zip=zip[1], state=state[1], numberOfSteps = mean(numberOfSteps, na.rm=T), distance = mean(distance, na.rm=T), hasDisease=max(hasDisease, na.rm=T))

heart.age <- by(heart.age, heart.age$healthCode, function(x){x[1,]})
heart.age <- data.frame(rbindlist(heart.age))
heart.age[heart.age$heartAgeDataEthnicity=="[]", "heartAgeDataEthnicity"] <- NA
heart.age[!is.na(heart.age$heartAgeDataEthnicity) & heart.age$heartAgeDataEthnicity=="[Alaska Native]", "heartAgeDataEthnicity"] <- "[American Indian]"
heart.age[!is.na(heart.age$heartAgeDataEthnicity) & heart.age$heartAgeDataEthnicity=="[I prefer not to indicate an ethnicity]", "heartAgeDataEthnicity"] <- "[Other]"
#browser()
risk <- risk[!duplicated(risk$healthCode),]
heart.age <- merge(heart.age,risk,by="healthCode",all.x=T)

heart.age$cholDrug = grepl("1", heart.age$medications_to_treat)
heart.age$bpDrug = grepl("2", heart.age$medications_to_treat)

heart.age$hasDisease <- heart.age$heart_disease != "[10]" & heart.age$heart_disease != "[]"
heart.age$hasDisease[heart.age$heart_disease == "[]"] = NA

heartage.summary <- by(heart.age, heart.age$heartAgeDataGender, summarize_heartage) 
heartage.summary <- do.call(cbind, heartage.summary)
heartage.summary <- round(heartage.summary, 2)

options(scipen=999)

# table 2 
# heart age, risk score, 6min, motion by decade
