import pandas as pd
import pdb 
from dateutil.parser import parse
double_counted=pd.read_csv("multiple_completers.txt",header=0,sep='\t')
double_counted_dict=dict() 
for index,row in double_counted.iterrows(): 
    subject=row['Subject'] 
    double_counted_dict[subject]=1 
#data=pd.read_csv("health_kit_combined.steps.txt.regression",header=0,sep='\t')
#data=pd.read_csv("motion_tracker_combined.txt.regression",header=0,sep='\t')
#data=pd.read_csv("sleep_healthkit_combined.txt.regression",header=0,sep='\t')
data=pd.read_csv("life_satisfaction.regression",header=0,sep='\t')

#keep a dictionary of subject -> d0 values, use the "earlier" of the d0 values to exclude any entries  > 35 days after the d0 value 
day0=dict() 
for index, row in data.iterrows(): 
    dayIndex=row['dayIndex'] 
    if dayIndex==0: 
        subject=row['Subject']
        date=parse(row['Date']).date()
        if subject not in day0: 
            day0[subject]=set([date])
        day0[subject].add(date)
print("parsed day 0 values for subjects") 
#outf=open('health_kit_combined.steps.txt.regression.nodoublecounting','w')
#outf=open('motion_tracker_combined.txt.regression.nodoublecounting','w')
#outf=open('sleep_healthkit_combined.txt.regression.nodoublecounting','w')
outf=open('life_satisfaction.regression.nodoublecounting','w')
header='\t'.join(data.columns) 
outf.write(header+'\n') 
for index,row in data.iterrows():
    subject=row['Subject'] 
    try:
        day0_subject=min(day0[subject])
        date=parse(row['Date']).date() 
        delta=abs((day0_subject - date).days)
    except: 
        delta=0
    if subject in double_counted_dict:
        if delta < 30:        
            outf.write('\t'.join([str(i) for i in row])+'\n')
        else: 
            print('\t'.join([str(i) for i in row]))

    else:
        outf.write('\t'.join([str(i) for i in row])+'\n')

    



