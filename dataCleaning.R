### Data cleaning for riskFactors.table
### Rachel Goldfeder


riskFactors <- synTableQuery("SELECT * FROM syn3420385")
riskFactors.table <- riskFactors@values


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


