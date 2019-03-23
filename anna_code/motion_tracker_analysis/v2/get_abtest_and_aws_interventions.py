import pickle as p 
import pandas as pd 
import pdb
from datetime import datetime,timedelta,date
from dateutil.parser import parse 
import sys  

def get_interventions(ab_test_file,aws_file_pickle,appVersion_file,intervention_days):
    #load the tables
    with open(aws_file_pickle,'rb') as f:         
        aws_data=p.load(f,encoding='bytes')
    ab_data=pd.read_csv(ab_test_file,header=0,sep='\t')
    appversion=pd.read_csv(appVersion_file,header=0,sep='\t')
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
            baseline_date=created_on-timedelta(days=d)         
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


    print("Determining appVersion for each healthCode/createOn")
    cur_count=0 
    for index,row in appversion.iterrows(): 
        cur_count+=1 
        if cur_count %1000==0: 
            print(cur_count) 
        subject=row['healthCode'] 
        cur_date=parse(row['createdOn']).date() 
        cur_appVersion=row['appVersion'] 
        if subject in subject_dict: 
            if cur_date in subject_dict[subject]: 
                subject_dict[subject][cur_date]['appVersion']=cur_appVersion 
    print("finished parsing ABTest/ AWS/ appVersion")
    return subject_dict



