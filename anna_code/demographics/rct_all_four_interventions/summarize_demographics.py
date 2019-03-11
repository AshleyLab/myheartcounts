#summarize demographics: age, sex, biogeo, version, subject
import argparse
from datetime import datetime

def parse_args():
    parser=argparse.ArgumentParser(description="demographics summary")
    parser.add_argument("--summary_tables",nargs="+")
    parser.add_argument("--outf")
    parser.add_argument("--subjects",default=None) 
    parser.add_argument("--start_date",default=None,help="specify a start_date and end_date if need demographics for a certain time period") 
    parser.add_argument("--end_date",default=None,help="specify a start_date and end_date if need demographics for a certain time period") 
    return parser.parse_args()

def get_indices(fname): 
    data=open(fname,'r').read().strip().split('\n')
    header=data[0].split('\t')
    subject_index=header.index('healthCode')+1
    version_index=header.index('appVersion')+1
    if 'heartAgeDataGender' in header:
        sex_index=[header.index('heartAgeDataGender')+1]
    else:
        sex_index=[header.index('NonIdentifiableDemographics.json.patientBiologicalSex')+1,header.index('NonIdentifiableDemographics.patientBiologicalSex')+1]        
    if 'heartAgeDataEthnicity' in header:
        ethnicity_index=header.index('heartAgeDataEthnicity')+1
    else:
        ethnicity_index=None
    if 'heartAgeDataAge' in header:
        age_index=[header.index('heartAgeDataAge')+1]
    else:
        age_index=[header.index('NonIdentifiableDemographics.json.patientCurrentAge')+1,header.index('NonIdentifiableDemographics.patientCurrentAge')+1]
    date_index=header.index('uploadDate')+1
    return data,subject_index,version_index,sex_index,ethnicity_index,age_index,date_index

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
    if args.subjects!=None: 
        allowed_subject_dict=dict() 
        allowed_subjects=open(args.subjects,'r').read().strip().split('\n') 
        for subject in allowed_subjects: 
            allowed_subject_dict[subject]=1 
    for fname in args.summary_tables:
        data,subject_index,version_index,sex_index,ethnicity_index,age_index,date_index =get_indices(fname) 
        for line in data[1::]:            
            tokens=line.split('\t')
            cur_date=datetime.strptime(tokens[date_index],'%Y-%m-%d')
            if start_date!=None: 
                if cur_date < start_date: 
                    continue 
            if end_date!=None: 
                if cur_date > end_date: 
                    continue 
            subject=tokens[subject_index]
            if args.subjects!=None: 
                if subject not in allowed_subject_dict:
                    continue 
            subjects.add(subject) 
            version=tokens[version_index]
            if subject not in age_dict:
                age_dict[subject]="NA"
            if subject not in sex_dict:
                sex_dict[subject]="NA"
            if subject not in ethnicity_dict:
                ethnicity_dict[subject]="NA"
            if subject not in version_dict:
                version_dict[subject]=[version]
            else:
                version_dict[subject].append(version)

            
            sex=[tokens[ind] for ind in sex_index]
            if 'NA' in sex:
                sex.remove('NA')
            if len(sex)==0:
                sex='NA'
            else:
                sex=sex[0]
            if sex!="NA":
                sex_dict[subject]=sex
                
            age=[tokens[ind] for ind in age_index]
            if 'NA' in age: 
                age.remove('NA')
            if len(age)==0:
                age='NA'
            else:
                age=age[0]
            if age!="NA":
                age_dict[subject]=age
                
            if ethnicity_index!=None:
                ethnicity=tokens[ethnicity_index]
            else:
                ethnicity="NA"
            if ethnicity!="NA":
                ethnicity_dict[subject]=ethnicity
    for subject in subjects:
        for version in version_dict[subject]:
            outf.write(subject+'\t'+age_dict[subject]+'\t'+sex_dict[subject]+'\t'+ethnicity_dict[subject]+'\t'+version+'\n')
        
if __name__=="__main__":
    main()
    
