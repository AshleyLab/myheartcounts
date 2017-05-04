#NOTE: tested on python 2.7 w/ anaconda 2
#Author: annashch@stanford.edu

import numpy as np
from datetime import datetime
import pandas as pd
#from matplotlib.dates import strpdate2num
#import time 

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
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'i')

    data=np.loadtxt(table_path,
                    dtype=dtype_dict,
                    delimiter='\t',
                    skiprows=1)
    #do the timestamp conversion
    data['createdOn']=[datetime.strptime(entry,"%Y-%m-%d %H:%M:%S") for entry in data['createdOn']]
    data['uploadDate']=[datetime.strptime(entry,"%Y-%m-%d %H:%M:%S") for entry in data['uploadDate']]
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
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'i')
                          
    data=np.loadtxt(table_path,
                    dtype=dtype_dict,
                    delimiter='\t',
                    converters={4: lambda x: datetime.strptime(x, "%Y-%m-%d"),
                                8: lambda x: datetime.strptime(x, "%Y-%m-%d %H:%M:%S")},
                    skiprows=1)


def load_healthkit(table_path):
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
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'S36',
                           'i')
                          
    data=np.loadtxt(table_path,
                    dtype=dtype_dict,
                    delimiter='\t',
                    converters={4: lambda x: datetime.strptime(x, "%Y-%m-%d"),
                                8: lambda x: datetime.strptime(x, "%Y-%m-%d %H:%M:%S")},
                    skiprows=1)

#strpdate2num('%m/%d/%Y')
#TESTS
import pdb
#these are for Sherlock
base_dir="/scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/"
abtest_data=load_abtest(base_dir+"cardiovascular-ABTestResults-v1.tsv")
motionactivity_data=load_motion_activity(base_dir+"cardiovascular-motionActivityCollector-v1.tsv")
healthkit_data=load_healthkit(base_dir+"cardiovascular-HealthKitDataCollector-v1.tsv")
pdb.set_trace()
