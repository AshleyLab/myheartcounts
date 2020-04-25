# -*- coding: utf-8 -*-
"""
Created on Fri Apr 19 11:11:54 2019

Extracts aws activity reports for pretty graph making

@author: Daniel Wu
"""

import gzip
import json
import numpy as np

important_events = ['EligibilityTestPass']
out_file_path = '/scratch/PI/euan/projects/mhc/code/daniel_code/aws/EligibilityTestPass.txt'
out_file = open(out_file_path, 'a')

#Table with AWS to healthcode mappings
source_table="/scratch/PI/euan/projects/mhc/data/tables/cardiovascular-AwsClientIdTask-v1.tsv"


#Anna's function to map AWS client IDs to healthcodes, returns dict
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
        client_id_to_health_code_id[line['AwsClientId'].decode('UTF-8')] = line['healthCode'].decode('UTF-8')    
    return client_id_to_health_code_id


def criteria(json_data):
    '''
    Helper function that returns a bool representing whether to process json_data
    '''
    return json_data['event_type'] in important_events

def process_data(json_data):
    '''
    Helper function that processes a single json_data aws record
    '''
    out_file.write("{}\n".format(json.dumps(json_data)))
    
# =============================================================================
# Do the actual data parsing
# =============================================================================
#Load file
with open('/scratch/PI/euan/projects/mhc/data/aws.all', 'r') as filenames:
    
    for f in filenames:
        #load and read in file data
        with gzip.open(f.rstrip('\n'),'rb') as jf: 
            #Each .gz contains multiple jsons and some random empty (unix) linebreaks
            data=[json.loads(line) for line in jf.read().decode('UTF-8').split('\n') if line!='']
            
            
            #Iterate through each record in the file
            for datapoint in data:
                
                
                #Process valid datapoints
                if(criteria(datapoint)):
                    
                    process_data(datapoint)
                    

#CLOSE THE FILE
out_file.close()
            
