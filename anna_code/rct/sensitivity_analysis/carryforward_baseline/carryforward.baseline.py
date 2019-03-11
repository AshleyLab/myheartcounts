import pandas as pd 
import pdb 
outf=open("carryforward.baseline.txt",'w') 
outf.write("Subject\tABTest\tValue\n")
data=pd.read_csv("health_kit_combined.instudy.steps.txt",header=0,sep='\t')
val_dict=dict() 
phases=["baseline","cluster","read_aha","stand","walk"]
for index,row in data.iterrows(): 
    cur_subject=row['Subject'] 
    cur_phase=row['ABTest'] 
    if str(cur_phase)=="NONE": 
        cur_phase="baseline" 
    cur_val=row['Value'] 
    if cur_subject not in val_dict: 
        val_dict[cur_subject]=dict() 
    if cur_phase not in val_dict[cur_subject]: 
        val_dict[cur_subject][cur_phase]=[cur_val] 
    else: 
        val_dict[cur_subject][cur_phase].append(cur_val) 
print("parsed through phases") 
#carry forward baseline values for missing entries
for subject in val_dict: 
    for phase in phases:  
        if phase in val_dict[subject]: 
            for entry in val_dict[subject][phase]: 
                outf.write(subject+'\t'+phase+'\t'+str(entry)+'\n')
        else: 
            try:
                for entry in val_dict[subject]['baseline']: 
                    outf.write(subject+'\t'+phase+'\t'+str(entry)+'\n')
            except: 
                print("skipping:"+subject+":"+phase)

