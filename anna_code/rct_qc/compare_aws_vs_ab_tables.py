import pickle as p 
import pandas as pd 
import pdb
from datetime import datetime,timedelta,date
from dateutil.parser import parse 

#constants
baseline_days=7
intervention_days=7

#load the tables
aws_data=p.load(open("aws_interventions.p",'rb'))
ab_data=pd.read_csv("cardiovascular-ABTestResults-v1.tsv",header=0,sep='\t')
steps=pd.read_csv('healthkit_combined.stepcount.txt',header=0,sep='\t')
distance=pd.read_csv('healthkit_combined.distance.txt',header=0,sep='\t')
appversion=pd.read_csv("appVersionWithDates.tsv",header=None,sep='\t')
print("loaded tables of interest") 

#use a dictionary to keep track of AB-test values,AWS values, HealthKit steps, HealthKit distance 
subject_dict=dict() 

#get the AB-test information for each subject 
for index,row in ab_data.iterrows():
    health_code=row['healthCode']
    if health_code not in subject_dict: 
        subject_dict[health_code]=dict() 
    created_on=parse(row['createdOn']).date() 
    days_in_study=row['ABTestResult.days_in_study']
    
    #the days in range(1,days_in_study) before created_on date constitute the baseline week of data 
    first_baseline=created_on-timedelta(days=days_in_study)
    for d in range(1,days_in_study+1):
        baseline_date=create_on-timedelta(days=d)         
        if baseline_date not in subject_dict[health_code]: 
            subject_dict[health_code][baseline_date]=dict() 
        subject_dict[health_code][baseline_date]['ABTest']='baseline'
            
    #assign 7 days to each of the 4 interventions, breaking out of the loops
    # once days_in_study days have been accounted for 
    interventions=row['ABTestResult.variable_value'].split(',')
    final_date=created_on+timedelta(days=len(interventions)*intervention_days)
    cur_date=created_on
    for intervention in interventions: 
        days_in_cur_intervention=0
        while(days_in_cur_intervention < intervention_days):
            if cur_date not in subject_dict[health_code]: 
                subject_dict[health_code][cur_date]=dict() 
            subject_dict[health_code][cur_date]['ABTest']=intervention 
            cur_date+=timedelta(days=1)
            days_in_cur_intervention+=1
            if cur_date >final_date: 
                break
        if cur_date > final_date: 
            break 

print("Assigned AB-test intervention schedule to all subjects")
print("Overlaying AWS analytics")
for subject in aws_data: 
    for cur_date in aws_data[subject]: 
        aws_scheduled=str(aws_data[subject][cur_date])
        if subject not in subject_dict: 
            subject_dict[subject]=dict() 
        if cur_date not in subject_dict[subject]:
            subject_dict[subject][cur_date]=dict() 
            #THIS IS AN ERROR CASE -- THERE IS NO AB TEST COACHING SCHEDULED! 
            subject_dict[subject][cur_date]['ABTest']="NONE"
        subject_dict[subject][cur_date]['AWS']=aws_scheduled 


print("Assigned AWS analytics schedule to all subjects")
print("Overlaying HealthKit Steps") 
for index,row in steps.iterrows(): 
    subject=row['Subject'] 
    cur_date=parse(row['Date']).date()
    step_count=row['Value'] 
    step_source=row['Source']
    step_blobs=row['SourceBlobs']
    if subject not in subject_dict: 
        subject_dict[subject]=dict() 
    if cur_date not in subject_dict[subject]: 
        subject_dict[subject][cur_date]=dict() 
        #ERROR CASE -- WHY DON'T WE HAVE STEPS FOR THIS PERSON/DATE -- @ANNA -CHECK
        subject_dict[subject][cur_date]['ABTest']="NONE"
        subject_dict[subject][cur_date]['AWS']="NONE" 
    if 'steps' not in subject_dict[subject][cur_date]:
        subject_dict[subject][cur_date]['steps']=[]
    subject_dict[subject][cur_date]['steps'].append('\t'.join([str(i) for i in [step_count,step_source,step_blobs]]))

print("Assigned HealthKit Steps to all subjects") 
print("Overlaying HealthKit Distance") 
for index,row in distance.iterrows(): 
    subject=row['Subject'] 
    cur_date=parse(row['Date']).date()
    dist_count=row['Value'] 
    dist_source=row['Source']
    dist_blobs=row['SourceBlobs']
    if subject not in subject_dict: 
        subject_dict[subject]=dict() 
    if cur_date not in subject_dict[subject]: 
        subject_dict[subject][cur_date]=dict() 
        #ERROR CASE -- WHY DON'T WE HAVE STEPS FOR THIS PERSON/DATE -- @ANNA -CHECK
        subject_dict[subject][cur_date]['ABTest']="NONE"
        subject_dict[subject][cur_date]['AWS']="NONE" 

    if 'dist' not in subject_dict[subject][cur_date]:
        subject_dict[subject][cur_date]['dist']=[] 
    subject_dict[subject][cur_date]['dist'].append('\t'.join([str(i) for i in [dist_count,dist_source,dist_blobs]]))

print("Assigned HealthKit Distance to all subjects") 
print("Determining appVersion for each healthCode/createOn")
for index,row in appversion.iterrows(): 
    subject=row['healthCode'] 
    cur_date=parse(row['createdOn']).date() 
    cur_appVersion=row['appVersion'] 
    if subject in subject_dict: 
        if cur_date in subject_dict[subject]: 
            subject_dict[subject][cur_date]['appVersion']=cur_appVersion 


print("Writing output file") 
outf=open("AWS_vs_ABTable_HealthKit_Steps_Distance.tsv",'w')
outf.write('\t'.join(['Subject','Date','ABTest','AWS','Metric','Value','Source','Blobs'])+'\n')
for subject in subject_dict: 
    for cur_date in subject_dict[subject]:
        if 'appVersion'] in subject_dict[subject][cur_date]:
            cur_appVersion=subject_dict[subject][cur_date]['appVersion']
        else: 
            cur_appVersion="NONE"

        if 'ABTest' in subject_dict[subject][cur_date]: 
            cur_abtest=subject_dict[subject][cur_date]['ABTest']
        else: 
            cur_abtest="NONE"

        if 'AWS' in subject_dict[subject][cur_date]: 
            cur_aws=subject_dict[subject][cur_date]['AWS'] 
        else: 
            cur_aws="NONE"

        if 'steps' in subject_dict[subject][cur_date]: 
            for step_entry in subject_dict[subject][cur_date]['steps']: 
                try:
                    outf.write('\t'.join([subject,str(cur_date),cur_appVersion,cur_abtest,cur_aws,'HealthKitSteps',step_entry])+'\n')
                except: 
                    pdb.set_trace() 
        else: 
            outf.write('\t'.join([subject,str(cur_date),cur_appVersion,cur_abtest,cur_aws,'HealthKitSteps',"NONE"])+'\n')

        if 'dist' in subject_dict[subject][cur_date]:
            for dist_entry in subject_dict[subject][cur_date]['dist']: 
                outf.write('\t'.join([subject,str(cur_date),cur_appVersion,cur_abtest,cur_aws,'HealthKitDistance',dist_entry])+'\n')
        else:
            outf.write('\t'.join([subject,str(cur_date),cur_appVersion,cur_abtest,cur_aws,'HealthKitDistance',"NONE"])+'\n')

    
