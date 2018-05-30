#parse AWS data to identify on which days subjects were given specific interventions
import numpy as np 
import json 
import gzip 
from dateutil.parser import parse
import pdb 

#generate dictionary to map health code ids to AWS id's 
def map_aws_to_healthcode(source_table): 
    client_id_to_health_code_id=dict()
    #read in the data 
    dtype_dict=dict() 
    dtype_dict['names']=('skip',
                         'recordId',
                         'appVersion',
                         'phoneInfo',
                         'uploadDate',
                         'healthCode',
                         'externalId',
                         'dataGroups',
                         'createdOn',
                         'createdOnTimeZone',
                         'userSharingScope',
                         'validationErrors',
                         'AwsClientId')
    dtype_dict['formats']=('S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36')
    try: 
        data=np.genfromtxt(source_table,
                           names=dtype_dict['names'],
                           dtype=dtype_dict['formats'],
                           delimiter='\t',
                           skip_header=True,
                           loose=True,
                           invalid_raise=False)
    except:
        print("failed to load file:"+str(source_table))
        raise Exception() 

    #create a mapping of client id to healthCode 
    for line in data: 
        client_id_to_health_code_id[line['AwsClientId'].decode('UTF-8')]=line['healthCode'].decode('UTF-8')    
    return client_id_to_health_code_id

def parse_json(data,interventions,client_id_to_health_code_id): 
    event_type=data['event_type'] 
    #We only want to examine json objects of type CoachingNotificationScheduled
    if event_type!='CoachingNotificationScheduled': 
        return interventions
    #get the client id
    cur_client=data['client']['client_id']
    if cur_client not in client_id_to_health_code_id: 
        return interventions 
    cur_client=client_id_to_health_code_id[cur_client]
    #get the event type 
    action=data['attributes']['action']
    #get the event date 
    fireDate=parse(data['attributes']['fireDate']).date() 
    if cur_client not in interventions: 
        interventions[cur_client]=dict() 
    if fireDate not in interventions[cur_client]: 
        interventions[cur_client][fireDate]=set([action])
    else: 
        interventions[cur_client][fireDate].add(action)
    return interventions

#recursively parse through files located in base_dir to identify interventions per subject per timestamp 
#interventions are stored in json file format 
#file_names is a file that contains the name of an AWS gzipped json file on each row 
#(i.e. /scratch/PI/euan/projects/mhc/code/anna_code/motion_tracker_analysis/v2/aws.all)
def extract_interventions(file_names,client_id_to_health_code_id): 
    interventions=dict() 
    fnames=open(file_names,'r').read().strip().split('\n') 
    for f in fnames: 
        print(f)
        with gzip.open(f,'rb') as jf: 
            data=[json.loads(line) for line in jf.read().decode('UTF-8').split('\n') if line!='']
            for entry in data: 
                interventions=parse_json(entry,interventions,client_id_to_health_code_id)
    return interventions

if __name__=="__main__": 
    file_names="/scratch/PI/euan/projects/mhc/code/anna_code/motion_tracker_analysis/v2/aws.all"
    source_table="/scratch/PI/euan/projects/mhc/data/tables/cardiovascular-AwsClientIdTask-v1.tsv"
    client_id_to_health_code_id=map_aws_to_healthcode(source_table)    
    interventions=extract_interventions(file_names,client_id_to_health_code_id)
    #store the data in a pickle
    import pickle
    pickle.dump(interventions,open('aws_interventions.p','wb'))

