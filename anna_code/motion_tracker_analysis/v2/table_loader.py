#NOTE: tested on python 2.7 w/ anaconda 2
#Author: annashch@stanford.edu
import numpy as np
from datetime import datetime
from dateutil.parser import parse 

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
                         'ABTestResult.test_name',
                         'ABTestResult.variable_value',
                         'ABTestResult.days_in_study')
    dtype_dict['formats']=('S36',
                           'S36',
                           'S36',
                           'S36',
                           datetime,
                           'S36',
                           'S36',
                           'S36',
                           datetime,
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'i')

    data=np.loadtxt(table_path,
                    dtype=dtype_dict,
                    delimiter='\t',
                    skiprows=1,
                    converters={4:lambda x:parse(x),
                                8:lambda x:parse(x)})
    return data

def load_motion_activity(table_path):
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
                         'data') 
    dtype_dict['formats']=('S36',
                           'S36',
                           'S36',
                           'S36',
                           datetime,
                           'S36',
                           'S36',
                           'S36',
                           datetime,
                           'S36',
                           'S36',
                           'i')
                          
    data=np.loadtxt(table_path,
                    dtype=dtype_dict,
                    delimiter='\t',
                    converters={4: lambda x: parse(x),
                                8: lambda x: parse(x)},
                    skiprows=1)
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
                         'data') 
    dtype_dict['formats']=('S36',
                           'S36',
                           'S36',
                           'S36',
                           datetime,
                           'S36',
                           'S36',
                           'S36',
                           datetime,
                           'S36',
                           'S36',
                           'i')
                          
    data=np.loadtxt(table_path,
                    dtype=dtype_dict,
                    delimiter='\t',
                    converters={4: lambda x: parse(x),
                                8: lambda x: parse(x)},
                    skiprows=1)
    return data 

if __name__=="__main__":
    #TESTS for sherlock
    import pdb
    base_dir="/scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/"
    abtest_data=load_abtest(base_dir+"cardiovascular-ABTestResults-v1.tsv")
    motionactivity_data=load_motion_activity(base_dir+"cardiovascular-motionActivityCollector-v1.tsv")
    healthkit_data=load_healthkit(base_dir+"cardiovascular-HealthKitDataCollector-v1.tsv")

