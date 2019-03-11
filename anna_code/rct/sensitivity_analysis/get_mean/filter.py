import pandas as pd 
data=pd.read_csv("health_kit_combined.steps.txt",header=0,sep='\t')
subjects=open("subjects.v2",'r').read().strip().split('\n') 
subject_dict=dict() 
for subject in subjects: 
    subject_dict[subject]=1 
outf=open("health_kit_combined.instudy.steps.txt",'w') 
for index,row in data.iterrows(): 
    subject=row['Subject']
    if subject in subject_dict: 
        outf.write('\t'.join([str(i) for i in row])+'\n')

    
