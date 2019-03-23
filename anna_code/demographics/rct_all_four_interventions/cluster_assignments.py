import pickle 
import pandas as pd 
data=pickle.load(open("aws_cluster_assignments.p",'rb'))
subjects=open("/scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt",'r').read().strip().split('\n') 
aws_to_healthcode=pd.read_csv("/scratch/PI/euan/projects/mhc/data/tables/cardiovascular-AwsClientIdTask-v1.tsv",header=0,sep='\t')
aws_to_healthcode_dict=dict() 
for index,row in aws_to_healthcode.iterrows(): 
    aws_code=row['AwsClientId.clientId'] 
    healthcode=row['healthCode']
    aws_to_healthcode_dict[aws_code]=healthcode 
print("mapped AWS ID to healthcodes") 

allowed_subjects=dict() 
for subject in subjects: 
    allowed_subjects[subject]=1
print("got allowed subjects") 

outf=open("activity.clusters.txt",'w') 
outf.write("Subject\tCluster\n") 


subject_to_cluster=dict() 
for key in data: 
    for subject in data[key]['aws_id']: 
        if subject in allowed_subjects: 
            outf.write(subject+'\t'+key+'\n') 
        else: 
            try:
                cur_healthcode=aws_to_healthcode_dict[subject] 
                if cur_healthcode in allowed_subjects: 
                    outf.write(cur_healthcode+'\t'+key+'\n') 
            except: 
                continue 
