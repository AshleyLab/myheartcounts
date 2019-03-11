import pandas as pd 
import pdb 
import itertools 
outf=open("carryforward.mean.txt",'w') 
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
            allvals=val_dict[subject].values() 
            allvals=list(itertools.chain.from_iterable(allvals))
            allvals=[float(i) for i in allvals]
            mean_val=sum(allvals)/len(allvals) 
            mean_vals=[str(mean_val) for i in range(7)]
            try:
                for mean_val in mean_vals: 
                    outf.write(subject+'\t'+phase+'\t'+mean_val+'\n')
            except: 
                print("skipping:"+subject+":"+phase)

