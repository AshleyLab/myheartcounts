### Data cleaning for riskFactors.distinct
### Rachel Goldfeder



#######  RULES  ########

# things I'm okay with: 
# any number individually
# 1, 2 == 2 ,1  == mult == 11

#things I'm not okay with
# 3 + (1 || 2) => trash.
#[] => trash




for (var in c("vascular","family_history", "medications_to_treat","heart_disease")){ 
  # summarize the column
  opts = unique(riskFactors.distinct[,colnames(riskFactors.distinct)==var])
  
  # find max single number
  singles = opts[-grep(",",opts)]
  highest_val = sort(singles)[length(singles)] # this is going to be the one that cant be seen with othres -- or the "none"
  t = strsplit(highest_val,"\\[")
  highest.num = strsplit(t[[1]][2],"\\]")[[1]]
  
  # toss things with that single number and a comma
  mults = opts[grep(",",opts)]
  trash = mults[grep(highest.num,mults)]
  trash = append(trash,"[]")
  
  # then collapse anything else with a comman into "mult"
  mults.to.keep = mults[!(mults %in% trash)]

  
  riskFactors.distinct[riskFactors.distinct[,colnames(riskFactors.distinct)==var]%in%trash,colnames(riskFactors.distinct)==var ] <- NA
  riskFactors.distinct[riskFactors.distinct[,colnames(riskFactors.distinct)==var]%in%mults.to.keep,colnames(riskFactors.distinct)==var ] <- "mult"
  
}







#family_history 
# 1 = father
# 2 = mother
# 3 = none









#medications
# 1 = cholesterol
# 2 = hypertension
# 3 = diabetes
# 4 = none







#heart disease
# 1 = heart attack
# 2 = heart bypass surgery
# 3 = coronary blockage 
# 4 = coronary stent
# 5 = angina
# 6 = high coronary calcium 
# 7 = heart failure
# 8 = atrial fib
# 9 = congenital heart defect
# 10 = none






#vascular
# 1 = stroke
# 2 = transient ischemic attack
# 3 = carotid artery blockage
# 4 = carotid artery surgery 
# 5 = peripheral vascular disease
# 6 = abdominal aortic anuerysm
#7 = none


