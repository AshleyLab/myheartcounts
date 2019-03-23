import pandas as pd 
subject_to_intervention=dict() 
data=pd.read_csv("data.txt",header=0,sep='\t') 
interventions=set() 
for index,row in data.iterrows(): 
    subject=row['Subject'] 
    intervention=row['ABTest'] 
    if intervention=="declined": 
        continue 
    interventions.add(intervention) 
    if subject not in subject_to_intervention: 
        subject_to_intervention[subject]=set(intervention) 
    else: 
        subject_to_intervention[subject].add(intervention) 
print(interventions) 
outf=open("subjects_who_did_all_interventions.txt",'w') 
for subject in subject_to_intervention: 
    if (len(subject_to_intervention[subject])==5): 
        outf.write(subject+'\n')
