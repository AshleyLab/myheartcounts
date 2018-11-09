import pandas as pd
from numpy import mean 
data=pd.read_csv("data.txt",header=0,sep='\t')
allowed_interventions=['baseline','cluster','read_aha','stand','walk']
vals=dict()
outf=open("mean_intervention_deltas.txt",'w')
for index,row in data.iterrows():
    subject=row['Subject']
    intervention=row['ABTest']
    value=row['Value']
    if intervention in allowed_interventions:
        if subject not in vals:
            vals[subject]=dict()
        if intervention not in vals[subject]:
            vals[subject][intervention]=[value]
        else:
            vals[subject][intervention].append(value)
print("parsed")
for subject in vals:
    try:
        subject_baseline=mean(vals[subject]['baseline'])
        for intervention in allowed_interventions[1::]:
            if intervention in vals[subject]:
                cur_delta=mean(vals[subject][intervention])-subject_baseline
                outf.write(subject+'\t'+intervention+'\t'+str(cur_delta)+'\n')
    except:
        continue
            
        
