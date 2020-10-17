#summarize demographics: age, sex, biogeo, version, subject
import argparse
import pandas as pd 
import numpy as np 
from datetime import datetime

def parse_args():
    parser=argparse.ArgumentParser(description="demographics summary")
    parser.add_argument("--summary_tables",nargs="+")
    parser.add_argument("--outf")
    parser.add_argument("--start_date",default=None,help="specify a start_date and end_date if need demographics for a certain time period") 
    parser.add_argument("--end_date",default=None,help="specify a start_date and end_date if need demographics for a certain time period") 
    return parser.parse_args()

def get_indices(data): 
    columns=data.columns.tolist() 
    if 'heartAgeDataGender' in columns: 
        sex_index=[columns.index('heartAgeDataGender')] 
    else: 
        sex_index=[columns.index('NonIdentifiableDemographics.json.patientBiologicalSex'),columns.index('NonIdentifiableDemographics.patientBiologicalSex')]
    if 'heartAgeDataEthnicity' in columns:
        ethnicity_index=columns.index('heartAgeDataEthnicity')
    else:
        ethnicity_index=None
    if 'heartAgeDataAge' in columns:
        age_index=[columns.index('heartAgeDataAge')]
    else:
        age_index=[columns.index('NonIdentifiableDemographics.json.patientCurrentAge'),columns.index('NonIdentifiableDemographics.patientCurrentAge')]
    return sex_index,ethnicity_index,age_index

def main():
    args=parse_args()
    outf=open(args.outf,'w')
    outf.write('Subject\tAge\tSex\tAncestry\tVersion\n')

    subject_dict=dict()
    age_dict=dict()
    sex_dict=dict() 
    ethnicity_dict=dict()
    version_dict=dict() 
    subjects=set([])
    start_date=None
    end_date=None
    if args.start_date!=None: 
        start_date=datetime.strptime(args.start_date,'%Y-%m-%d')
    if args.end_date!=None:
        end_date=datetime.strptime(args.end_date,'%Y-%m-%d') 
    for fname in args.summary_tables:
        data=pd.read_csv(fname,header=0,sep='\t',parse_dates=['uploadDate'])
        sex_index,ethnicity_index,age_index=get_indices(data)
        for index,row in data.iterrows(): 
            if start_date!=None: 
                if cur_date < start_date: 
                    continue 
            if end_date!=None: 
                if cur_date > end_date: 
                    continue 
            subject=row['healthCode']
            subjects.add(subject) 
            version=row['appVersion']
            if subject not in version_dict:
                version_dict[subject]=[version]
            else:
                version_dict[subject].append(version)

            
            sex=list(set([row[ind] for ind in sex_index]))
            print(sex)
            while np.nan in sex: 
                sex.remove(np.nan)
            if 'NA' in sex:
                sex.remove('NA')
            if len(sex)==0:
                sex='NA'
            else:
                if 'Female' in str(sex[0]): 
                    sex='Female'
                elif 'Male' in str(sex[0]): 
                    sex='Male' 
                else: 
                    sex='NA'
            sex_dict[subject]=sex
                
            age=[row[ind] for ind in age_index]
            while np.nan in age: 
                age.remove(np.nan) 
            if 'NA' in age: 
                age.remove('NA')
            if len(age)==0:
                age='NA'
            else:
                age=age[0]
            age_dict[subject]=age
                
            if ethnicity_index!=None:
                ethnicity=row[ethnicity_index]                
            else:
                ethnicity="NA"
            if 'Alaska' in ethnicity: 
                ethnicity='Alaska Nataive' 
            elif 'American' in ethnicity: 
                ethnicity='American Indian' 
            elif 'Asian' in ethnicity: 
                ethnicity='Asian'
            elif 'Black' in ethnicity: 
                ethnicity='Black'
            elif 'Hispanic' in ethnicity: 
                ethnicity='Hispanic'
            elif 'White' in ethnicity: 
                ethnicity='White'
            elif 'Pacific' in ethnicity: 
                ethnicity='Pacific Islander'
            elif 'Other' in ethnicity: 
                ethnicity='Other'
            elif 'prefer' in ethnicity: 
                ethnicity='I prefer not to indicate an ethnicity'
            ethnicity_dict[subject]=ethnicity

    for subject in subjects:
        for version in version_dict[subject]:
            outf.write(subject+'\t'+str(age_dict[subject])+'\t'+str(sex_dict[subject])+'\t'+str(ethnicity_dict[subject])+'\t'+str(version)+'\n')
        
if __name__=="__main__":
    main()
    
