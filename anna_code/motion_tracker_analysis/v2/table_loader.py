#NOTE: tested on python 2.7 w/ anaconda 2
#Author: annashch@stanford.edu
import numpy as np
from datetime import datetime
from dateutil.parser import parse 
#from io import StringIO

def convert_datetime(x):
    if x=="NA":
        return np.nan
    else:
        return parse(x)
    
def convert_int(x):
    if x=="NA":
        return np.nan
    else:
        return int(float(x)) 

def convert_float(x):
    if x=="NA":
        return np.nan
    else:
        return float(x)     
    
def load_abtest(table_path):
    dtype_dict=dict()
    dtype_dict['names']=('ID',
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
                         'ABTestResult.test_name',
                         'ABTestResult.variable_value',
                         'ABTestResult.days_in_study')
    dtype_dict['formats']=('U36',
                           'U36',
                           'U36',
                           'U36',
                           datetime,
                           'U36',
                           'U36',
                           'U36',
                           datetime,
                           'U36',
                           'U36',
                           'U36',
                           'U36',
                           'U36',
                           'f')
    data=np.genfromtxt(table_path,
                   dtype=dtype_dict['formats'],
                   names=dtype_dict['names'],
                   delimiter='\t',
                   skip_header=True,
                   loose=True,
                   invalid_raise=False,
                   converters={4:convert_datetime,
                               8:convert_datetime,
                               14:convert_int})

    return data

def load_motion_tracker(table_path):
    dtype_dict=dict()
    try:
        dtype_dict['names']=('ID',
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
                             'data') 
        dtype_dict['formats']=('U36',
                               'U36',
                               'U36',
                               'U36',
                               datetime,
                               'U36',
                               'U36',
                               'U36',
                               datetime,
                               'U36',
                               'U36',
                               'U36',
                               'U36')
        data=np.genfromtxt(table_path,
                           dtype=dtype_dict['formats'],
                           names=dtype_dict['names'],
                           delimiter='\t',
                           converters={4: convert_datetime,
                                       8: convert_datetime},
                           skip_header=True,
                           loose=True,
                           invalid_raise=False)
    except:
        dtype_dict['names']=('ID',
                             'recordId',
                             'healthCode',
                             'externalId',
                             'uploadDate',
                             'createdOn',
                             'appVersion',
                             'phoneInfo',
                             'data')
        dtype_dict['formats']=('U36',
                               'U36',
                               'U36',
                               'U36',
                               datetime,
                               datetime,
                               'U36',
                               'U36',
                               'U36')
        data=np.genfromtxt(table_path,
                           dtype=dtype_dict['formats'],
                           names=dtype_dict['names'],
                           delimiter='\t',
                           converters={4: convert_datetime,
                                       5: convert_datetime},
                           skip_header=True,
                           loose=True,
                           invalid_raise=False)
        
        
    return data


def load_health_kit(table_path):
    dtype_dict=dict()
    dtype_dict['names']=('ID',
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
                         'data') 
    dtype_dict['formats']=('U36',
                           'U36',
                           'U36',
                           'U36',
                           datetime,
                           'U36',
                           'U36',
                           'U36',
                           datetime,
                           'U36',
                           'U36',
                           'U36',
                           'U36')
    data=np.genfromtxt(table_path,
                       dtype=dtype_dict['formats'],
                       names=dtype_dict['names'],
                       delimiter='\t',
                       converters={4: convert_datetime,
                                   8: convert_datetime},
                       skip_header=True,
                       loose=True,
                       invalid_raise=True)
    return data 

if __name__=="__main__":
    #TESTS for sherlock
    import pdb
    base_dir="/scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/"
    abtest_data=load_abtest(base_dir+"cardiovascular-ABTestResults-v1.tsv")
    motionactivity_data=load_motion_tracker(base_dir+"cardiovascular-motionActivityCollector-v1.tsv")
    healthkit_data=load_health_kit(base_dir+"cardiovascular-HealthKitDataCollector-v1.tsv")
    pdb.set_trace()
    
