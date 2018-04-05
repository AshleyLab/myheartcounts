#parse AWS data to identify on which days subjects were given specific interventions
import numpy as np 
import json 
import gzip 
import pdb 

#generate dictionary to map health code ids to AWS id's 
def map_aws_to_healthcode(source_table): 
    client_id_to_health_code_id=dict()
    #read in the data 
    dtype_dict=dict() 
    dtype_dict['names']=('recordId',
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
    try: 
        data=np.genfromtxt(source_table,
                           names=dtype_dict['names'],
                           delimiter='\t',
                           skip_header=True,
                           loose=True,
                           invalid_raise=False)
    except:
        print("failed to load file:"+str(source_table))
        raise Exception() 

    #create a mapping of client id to healthCode 
    for line in data: 
        client_id_to_health_code_id[line['AwsClientId']]=line['healthCode']    
    return client_id_to_health_code_id

#recursively parse through files located in base_dir to identify interventions per subject per timestamp 
#interventions are stored in json file format 
#file_names is a file that contains the name of an AWS gzipped json file on each row 
#(i.e. /scratch/PI/euan/projects/mhc/code/anna_code/motion_tracker_analysis/v2/aws.all)
def extract_interventions(file_names): 
    interventions=dict() 
    fnames=open(file_names,'r').read().strip().split('\n') 
    for f in fnames: 
        with gzip.open(f,'rb') as jf: 
            data=[json.loads(line) for line in jf.read().decode('ascii').split('\n') if line!='']
            pdb.set_trace() 
    return interventions

if __name__=="__main__": 
    file_names="/scratch/PI/euan/projects/mhc/code/anna_code/motion_tracker_analysis/v2/aws.all"
    interventions=extract_interventions(file_names)
    
