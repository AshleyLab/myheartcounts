import sys 
import pandas as pd 
rct_subjects=open('one_plus_interventions/subjects.txt','r').read().strip().split('\n') 
rct_subject_dict=dict() 
for line in rct_subjects: 
    rct_subject_dict[line]=1 
print('made dictionary of rct subjects') 
data=open(sys.argv[1],'r').read().strip().split('\n') 
tally=dict() 
for line in data: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    if subject in rct_subject_dict: 
        val=tokens[1] 
        if val not in tally: 
            tally[val]=1
        else: 
            tally[val]+=1 
print(str(tally))
