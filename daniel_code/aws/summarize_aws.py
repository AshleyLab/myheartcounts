# -*- coding: utf-8 -*-
"""
Created on Fri Apr 19 11:11:54 2019

Simply counts the number of each type of aws signal and the attributes that come with it
Produces a pickled dictionary containing fields
"total" = total number of data points
"[event_type]" = a field recording the number of occurances of each event type
"([event_type], [attribute])" = a field recording the number of occurences of each report of a certain event type with a certain attribute
"unique_ids" = a field containing a set of all the ids which sent reports

@author: Daniel Wu
"""

import gzip
import json
import numpy as np
import pickle

out_file_path = '/scratch/PI/euan/projects/mhc/code/daniel_code/aws/summary.pkl'

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


def process_data(json_data, summary_info):
    '''
    Helper function that processes a single json_data aws report
    and records its occurance in the total dictionary
    '''
    
    event_type = json_data.get("event_type", "INVALID_EVENT")
    
    summary_info["total"] += 1
    
    if json_data.get("client", None) != None:
        summary_info["unique_ids"].add(json_data["client"].get("client_id", "INVALID_ID"))
        
    summary_info[event_type] = summary_info.get(event_type, 0) + 1
    
    #Log each of the attributes
    for key in json_data.get("attributes", {}).keys():
        summary_info[(event_type, key)] = summary_info.get((event_type, key), 0) + 1
    
# =============================================================================
# Do the actual data parsing
# =============================================================================

#Dictionary to store the summary of the data
summary_info = {"total" : 0, "unique_ids" : set()}

#Load file
with open('/scratch/PI/euan/projects/mhc/data/aws.all', 'r') as filenames:
    
    for f in filenames:
        #load and read in file data
        with gzip.open(f.rstrip('\n'),'rb') as jf: 
            #Each .gz contains multiple jsons and some random empty (unix) linebreaks
            data=[json.loads(line) for line in jf.read().decode('UTF-8').split('\n') if line!='']
            
            
            #Iterate through each record in the file
            for datapoint in data:
                
                #Process datapoints                    
                process_data(datapoint, summary_info)
                    
#Save results
with open(out_file_path, 'wb') as handle:
    pickle.dump(summary_info, handle, protocol=pickle.HIGHEST_PROTOCOL)
