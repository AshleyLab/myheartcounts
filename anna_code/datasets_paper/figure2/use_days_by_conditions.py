import argparse 
import pandas as pd 
import pdb 
from dateutil.parser import parse

def parse_args(): 
    parser=argparse.ArgumentParser(description="creates a dataframe with subject\tdays_in_study\tPresence or absence of conditions")
    parser.add_argument("--app_version_table")
    parser.add_argument("--cardiovascular_risk_tables",nargs="+",default=[]) 
    parser.add_argument("--life_satisfaction_tables",nargs="+",default=[]) 
    parser.add_argument("--outf") 
    return parser.parse_args() 


def main(): 
    args=parse_args() 
    app_version=pd.read_csv(args.app_version_table,header=0,sep='\t') 
    #generate a dictionary with the number of days of data for each healthCode 
    subject_days=dict() 
    for index,row in app_version.iterrows():
        subject=row['healthCode']
        cur_date=parse(row['createdOn']).date() 
        if subject not in subject_days: 
            subject_days[subject]=set([cur_date]) 
        else: 
            subject_days[subject].add(cur_date) 
    print("got summary of number of days of data per subject") 


    subject_conditions=dict() 
    for file_name in args.cardiovascular_risk_tables:
        cardio_risk=pd.read_csv(file_name,header=0,sep='\t') 
        for index,row in cardio_risk.iterrows(): 
            subject=row['healthCode'] 
            if subject not in subject_conditions: 
                subject_conditions[subject]=dict() 
            family_history=row['family_history'] 
            heart_disease=row['heart_disease'] 
            vascular_disease=row['vascular']
            if (family_history.__contains__("3")):
                subject_conditions[subject]['family_history']=False
            elif(family_history.__contains__("NA")):
                subject_conditions[subject]['family_history']="NA"
            else:
                subject_conditions[subject]['family_history']=True 

            if heart_disease.__contains__("10"): 
                subject_conditions[subject]['heart_disease']=False
            elif heart_disease.__contains__("NA"): 
                subject_conditions[subject]['heart_disease']="NA"
            else: 
                subject_conditions[subject]['heart_disease']=True

            if vascular_disease.__contains__("7"): 
                subject_conditions[subject]['vascular_disease']=False  
            elif vascular_disease.__contains__("NA"): 
                subject_conditions[subject]['vascular_disease']="NA" 
            else: 
                subject_conditions[subject]['vascular_disease']=True 
    print("got summary of family_history, heart_disease, vascular_disease") 
    for file_name in args.life_satisfaction_tables:
        life_satisfaction=pd.read_csv(file_name,header=0,sep='\t')        
        for index,row in life_satisfaction.iterrows(): 
            subject=row['healthCode'] 
            worthwhile=row['feel_worthwhile1']
            happy=row['feel_worthwhile2']
            worried=row['feel_worthwhile3']
            depressed=row['feel_worthwhile4']
            riskfactors1=row['riskfactors1']
            riskfactors2=row['riskfactors2']
            riskfactors3=row['riskfactors3']
            riskfactors4=row['riskfactors4']
            if subject not in subject_conditions: 
                subject_conditions[subject]=dict() 
            subject_conditions[subject]['worthwhile']=worthwhile
            subject_conditions[subject]['happy']=happy
            subject_conditions[subject]['worried']=worried
            subject_conditions[subject]['depressed']=depressed
            subject_conditions[subject]['riskfactors1']=riskfactors1
            subject_conditions[subject]['riskfactors2']=riskfactors2
            subject_conditions[subject]['riskfactors3']=riskfactors3
            subject_conditions[subject]['riskfactors4']=riskfactors4
    #write the output file
    outf=open(args.outf,'w') 
    outf.write('Subject\tDaysWithData\tFamilyHistory\tHeartDisease\tVascularDisease\tWorthwhile\tHappy\tWorried\tDepressed\tRisk1\tRisk2\tRisk3\tRisk4\n')
    for subject in subject_days: 
        if subject not in subject_conditions: 
            subject_conditions[subject]=dict() 
        num_days=len(subject_days[subject])
        outf.write(subject+'\t'+str(num_days))
        for category in ['family_history','heart_disease','vascular_disease','worthwhile','happy','worried','depressed','riskfactors1','riskfactors2','riskfactors3','riskfactors4']: 
            if category in subject_conditions[subject]: 
                outf.write('\t'+str(subject_conditions[subject][category]))
            else: 
                outf.write('\tNA') 
        outf.write('\n') 
 

if __name__=="__main__": 
    main() 
