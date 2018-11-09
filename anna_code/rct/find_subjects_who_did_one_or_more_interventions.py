#subset the step data from the iphone to include just the subjects who completed all 4 interventions 
import pandas as pd 
import pdb
data=pd.read_csv("health_kit_combined.steps.txt.regression.phone",sep='\t',header=0)
subject_to_interventions=dict() 
for index,row in data.iterrows(): 
    subject=row['Subject'] 
    intervention=row['ABTest'] 
    if subject not in subject_to_interventions: 
        subject_to_interventions[subject]=set([intervention])
    else: 
        subject_to_interventions[subject].add(intervention)
pdb.set_trace() 
print("got subject/intervention dictionary") 
outf=open("one_or_more_interventions.txt",'w')
data=open("health_kit_combined.steps.txt.regression.phone",'r').read().strip().split('\n') 
outf.write(data[0]+'\n') 
for line in data[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    interventions=subject_to_interventions[subject] 
    if 'baseline' in interventions: 
        if (len(interventions)>1): 
            print(str(subject_to_interventions[subject]))
            outf.write(line+'\n') 

    

