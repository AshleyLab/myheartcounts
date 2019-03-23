import pandas as pd 
import pdb
from datetime import datetime,timedelta,date
from dateutil.parser import parse 
abtest_data=pd.read_csv("../cardiovascular-ABTestResults-v1.tsv",header=0,sep='\t')
triangle_data=pd.read_csv("../AWS_vs_ABTable_HealthKit_Steps_Distance.tsv",header=0,sep='\t')

aws_abtest_combos=dict() 
#AWS and ABTest are None when they shouldn't be 
bad_none_entries=0
no_consent=[]

#generate a dictionary of subject date ranges
study_dates=dict() 
for index,row in abtest_data.iterrows(): 
    subject=row['healthCode']
    if subject not in study_dates:
        study_dates[subject]=[]
    created_on=parse(row['createdOn']).date()
    days_in_study=row['ABTestResult.days_in_study']
    starting_date=created_on-timedelta(days=days_in_study)
    final_date=created_on+timedelta(days=7*4)
    study_dates[subject].append((starting_date,final_date))


for index,row in triangle_data.iterrows(): 
    abtest_value=row['ABTest'] 
    aws_value=row['AWS'] 
    entry=(abtest_value,aws_value)
    if entry not in aws_abtest_combos: 
        aws_abtest_combos[entry]=1
    else: 
        aws_abtest_combos[entry]+=1
    if ((aws_value=="NONE") and (abtest_value=="NONE")):
        flag=0 
        #check that this is in the allowable date range 
        subject=row['Subject']
        cur_date=parse(row['Date']).date() 
        if subject not in study_dates: 
            no_consent.append(subject) 
        else: 
            for range_val in study_dates[subject]: 
                start_date=range_val[0] 
                end_date=range_val[1] 
                if ((cur_date > start_date) and (cur_date < end_date)):
                    flag=1
                    break
            if flag==1: 
                bad_none_entries+=1

print("bad none entries:"+str(bad_none_entries))
outf=open("AWS_ABTest_combo_tallies.tsv",'w')
outf.write("ABTest\tAWS\tCount\n")
for entry in aws_abtest_combos: 
    outf.write(entry[0]+'\t'+entry[1]+'\t'+str(aws_abtest_combos[entry])+'\n')

outf=open("no_consent_for_coaching.tsv",'w')
outf.write('\n'.join(no_consent)+'\n')
