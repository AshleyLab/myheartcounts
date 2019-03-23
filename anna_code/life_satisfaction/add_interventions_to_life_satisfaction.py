import pandas as pd 
import datetime 
import pdb
ls=pd.read_csv("satisfied_with_life.txt",header=0,sep='\t')
print("read in life satisfaction survey responses") 
interventions=pd.read_csv("interventions",header=0,sep='\t')
intervention_dict=dict() 
for index,row in interventions.iterrows(): 
    subject=row['Subject'] 
    date=datetime.datetime.strptime(row['Date'],'%Y-%m-%d').date()
    cur_intervention=row['ABTest'] 
    if subject not in intervention_dict: 
        intervention_dict[subject]=dict() 
    intervention_dict[subject][date]=cur_intervention 
print("generated intervention dict") 
#get days when coaching began 
subject_to_start_date=dict() 
start_dates=open("/scratch/PI/euan/projects/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv",'r').read().strip().split('\n') 
for line in start_dates[1::]: 
    tokens=line.split('\t') 
    subject=tokens[5] 
    created_on=datetime.datetime.strptime(tokens[8],'%Y-%m-%d %H:%M:%S').date() 
    if subject not in subject_to_start_date: 
        subject_to_start_date[subject]=[created_on]
    else: 
        subject_to_start_date[subject].append(created_on) 
print("generated dictionary of coaching start dates") 
outf=open('life_satisfaction.regression','w')
outf.write('Subject\tDate\tIntervention\tDayIndex\tWorthwhile\tHappy\tWorried\tDepressed\tSatisfied\n')

valid_interventions=['baseline','cluster','read_aha','stand','walk']
valid_interventions_aws=['APHClusterModule','APHReadAHAWebsiteModule','APHStandModule','APHWalkModule']
for index,row in ls.iterrows(): 
    subject=row['Subject'] 
    try:
        cur_date=datetime.datetime.strptime(row['Date'],'%Y-%m-%d %H:%M:%S').date()
    except: 
        continue 
    worthwhile=row['Worthwhile']
    happy=row['Happy'] 
    worried=row['Worried'] 
    depressed=row['Depressed'] 
    satisfied=row['Satisfied'] 
    #get the current intervention 
    if subject not in intervention_dict: 
        continue 
    if cur_date not in intervention_dict[subject]: 
        continue 
    cur_intervention=intervention_dict[subject][cur_date] 
    #get the number of days in study 
    if subject not in subject_to_start_date: 
        continue 
    deltas=[(cur_date - i).days for i in subject_to_start_date[subject]]
    min_delta=deltas[0] 
    for d in deltas: 
        if abs(d) < abs(min_delta): 
            min_delta=d 
    day_index=min_delta 
    outf.write(subject+'\t'+str(cur_date)+'\t'+str(cur_intervention)+'\t'+str(day_index)+'\t'+str(worthwhile)+'\t'+str(happy)+'\t'+str(worried)+'\t'+str(depressed)+'\t'+str(satisfied)+'\n')

