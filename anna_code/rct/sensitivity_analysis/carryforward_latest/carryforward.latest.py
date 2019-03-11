import pandas as pd 
import pdb 
outf=open("carryforward.latest.txt",'w') 
outf.write("Subject\tABTest\tValue\n")
data=pd.read_csv("health_kit_combined.instudy.steps.txt",header=0,sep='\t')
from dateutil.parser import parse 
val_dict=dict() 

last_intervention=dict() 

phases=["baseline","cluster","read_aha","stand","walk"]
for index,row in data.iterrows(): 
    cur_subject=row['Subject'] 
    cur_phase=row['ABTest'] 
    cur_date=row['Date'] 
    if str(cur_phase)=="NONE": 
        cur_phase="baseline" 
    cur_val=row['Value'] 
    if cur_subject not in val_dict: 
        val_dict[cur_subject]=dict() 
    if cur_phase not in val_dict[cur_subject]: 
        val_dict[cur_subject][cur_phase]=[cur_val] 
    else: 
        val_dict[cur_subject][cur_phase].append(cur_val) 
    
    #keep track of the latest intervention for the subject
    if cur_subject not in last_intervention: 
        last_intervention[cur_subject]=dict() 
        cur_date=parse(cur_date) 
        last_intervention[cur_subject]['date']=cur_date 
        last_intervention[cur_subject]['intervention']=cur_phase 
    else: 
        cur_date=parse(cur_date) 
        if cur_date > last_intervention[cur_subject]['date']: 
            last_intervention[cur_subject]['date']=cur_date 
            last_intervention[cur_subject]['intervention']=cur_phase 
print("parsed through phases") 
#carry forward latest intervention for missing entries
for subject in val_dict: 
    for phase in phases:  
        if phase in val_dict[subject]: 
            for entry in val_dict[subject][phase]: 
                outf.write(subject+'\t'+phase+'\t'+str(entry)+'\n')
        else: 
            #get the last intervention for this subject 
            subject_last_intervention=last_intervention[subject]['intervention']
            for entry in val_dict[subject][subject_last_intervention]: 
                outf.write(subject+'\t'+phase+'\t'+str(entry)+'\n')

