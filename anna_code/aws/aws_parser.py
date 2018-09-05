#parse AWS data to identify on which days subjects were given specific interventions
import numpy as np 
import json 
import gzip 
from dateutil.parser import parse
import datetime
import pdb 
import sys 
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

def parse_json_cluster_assignments(data,assignments,client_id_to_health_code_id): 
    event_type=data['event_type']
    if event_type!='StanfordCoachingCluster': 
        return assignments 
    #get the cluster assignment 
    cur_cluster=data['attributes']['cluster'] 
    #get the client id 
    cur_client=data['client']['client_id'] 
    try:
        cur_client=client_id_to_health_code_id[cur_client]
    except: 
        print("failed cur_client mapping to healthCode, keeping AWS identifier")
    if cur_cluster not in assignments: 
        assignments[cur_cluster]=dict() 
        assignments[cur_cluster]['count']=1
        assignments[cur_cluster]['aws_id']=[cur_client]
    else: 
        assignments[cur_cluster]['count']+=1 
        assignments[cur_cluster]['aws_id'].append(cur_client) 
    return assignments 

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

def parse_json_declined(data,declined,client_id_to_health_code_id):
    event_type=data['event_type'] 
    #We only want to examine json objects of type CoachingNotificationScheduled
    if event_type!='StanfordCoaching': 
        return declined
    #get the client id
    cur_client=data['client']['client_id']
    if cur_client not in client_id_to_health_code_id: 
        print(cur_client+": no id match")
        return declined
    cur_client=client_id_to_health_code_id[cur_client]
    #get the event type 
    event=data['attributes']['event']
    #get the timestamp
    timestamp=data['session']['start_timestamp'] 
    curdate = datetime.datetime.fromtimestamp(timestamp / 1e3).date()
    if event=="declined": 
        if cur_client not in declined: 
            declined[cur_client]=[curdate]
        else: 
            declined[cur_client].append(curdate) 
    return declined 


#recursively parse through files located in base_dir to identify interventions per subject per timestamp 
#interventions are stored in json file format 
#file_names is a file that contains the name of an AWS gzipped json file on each row 
#(i.e. /scratch/PI/euan/projects/mhc/code/anna_code/motion_tracker_analysis/v2/aws.all)
def extract_interventions(fnames,client_id_to_health_code_id): 
    interventions=dict() 
    #fnames=open(file_names,'r').read().strip().split('\n') 
    for f in fnames: 
        #print(f)
        with gzip.open(f,'rb') as jf: 
            data=[json.loads(line) for line in jf.read().decode('UTF-8').split('\n') if line!='']
            for entry in data: 
                interventions=parse_json(entry,interventions,client_id_to_health_code_id)
    return interventions

def extract_cluster_assignments(fnames,client_id_to_health_code_id): 
    assignments=dict() 
    #fnames=open(file_names,'r').read().strip().split('\n') 
    total_names=str(len(fnames))
    counter=0 
    for f in fnames: 
        #print(f)
        counter+=1
        #if counter%10000==0: 
            #print(str(counter)+'/'+total_names)
        with gzip.open(f,'rb') as jf: 
            data=[json.loads(line) for line in jf.read().decode('UTF-8').split('\n') if line!='']
            for entry in data: 
                assignments=parse_json_cluster_assignments(entry,assignments,client_id_to_health_code_id)
    return assignments
    
def extract_declined_coaching(fnames,client_id_to_health_code_id): 
    declined=dict() 
    #fnames=open(file_names,'r').read().strip().split('\n') 
    for f in fnames: 
        print(f)
        with gzip.open(f,'rb') as jf: 
            data=[json.loads(line) for line in jf.read().decode('UTF-8').split('\n') if line!='']
            for entry in data: 
                declined=parse_json_declined(entry,declined,client_id_to_health_code_id)
    return declined

if __name__=="__main__": 
    file_names="/scratch/PI/euan/projects/mhc/data/aws.all"
    start_index=int(sys.argv[1])
    end_index=int(sys.argv[2]) 
    file_names=open(file_names,'r').read().strip().split('\n')[start_index:end_index]    
    source_table="/scratch/PI/euan/projects/mhc/data/tables/cardiovascular-AwsClientIdTask-v1.tsv"
    client_id_to_health_code_id=map_aws_to_healthcode(source_table)    
    print("starting parse!")
    import pickle
    if (sys.argv[3]=="interventions"): 
        #TO GET INTERVENIONS 
        interventions=extract_interventions(file_names,client_id_to_health_code_id)
        with open(str(str(start_index)+"_"+str(end_index)+"_aws_interventions.p"), 'wb') as f:
            pickle.dump(interventions, f)
    elif (sys.argv[3]=="cluster"): 
        #TO GET NUMBER OF PEOPLE ASSIGNED TO EACH CLUSTER 
        cluster_assignments=extract_cluster_assignments(file_names,client_id_to_health_code_id) 
        for key in cluster_assignments: 
            print(key+':'+str(cluster_assignments[key]['count']))
        with open(str("aws_cluster_assignments.p"), 'wb') as f:
            pickle.dump(cluster_assignments, f)
    elif (sys.argv[3]=="declined"):
        #TO GET NUMBER OF PEOPLE WHO DECLINED COACHING 
        declined=extract_declined_coaching(file_names,client_id_to_health_code_id) 
        print("writing output!")
        outf=open(str(start_index)+'.declined','w')
        for entry in declined: 
            for date_entry in declined[entry]: 
                outf.write(entry+'\t'+str(date_entry)+'\n')

    else:  
        print("invalid option specified") 
