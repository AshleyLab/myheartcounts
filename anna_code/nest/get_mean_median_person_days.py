import pandas as pd 
import pdb 
appVersion_path="cardiovascular-appVersion.tsv"
appVersion=pd.read_csv(appVersion_path,header=0,sep='\t') 
print("loaded appVersion") 
person_to_days=dict() 
for index,row in appVersion.iterrows(): 
    if index%1000==0: 
        print(index) 
        healthCode=row['healthCode'] 
        createdOn=row['createdOn'] 
        if healthCode not in person_to_days: 
            person_to_days[healthCode]=dict() 
        person_to_days[healthCode][createdOn]=1 
print("got person-days") 
for person in person_to_days: 
    person_to_days[person]=len(person_to_days[person])
person_days=list(person_to_days.values())
mean_person_days=sum(person_days)/len(person_days) 
import statistics 
median_person_days=statistics.median(person_days) 
print("mean person days:"+str(mean_person_days))
print("median person days:"+str(median_person_days))

