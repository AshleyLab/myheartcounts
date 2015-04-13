library(dbplyr)

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
      n.smk = sum(!is.na(x$smokingHistory)), t.smk = sum(x$smokingHistory==T,na.rm=T), f.smk = sum(x$smokingHistory==F,na.rm=T)
      n.smk = sum(!is.na(x$smokingHistory)), t.smk = sum(x$smokingHistory==T,na.rm=T), f.smk = sum(x$smokingHistory==F,na.rm=T)
      )
    }

heartage.summary <- by(heart.age, heart.age$heartAgeDataGender, summarize_heartage) 
heartage.summary <-  do.call(cbind, heartage.summary)
heartage.summary <- round(heartage.summary, 2)

options(scipen=999)

# table 2 
# heart age, risk score, 6min, motion by decade
