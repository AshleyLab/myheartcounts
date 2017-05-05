#NOTE: tested on python 2.7 w/ anaconda 2
#Author: annashch@stanford.edu
import numpy as np
from datetime import datetime,timedelta
from dateutil.parser import parse
import pdb 
sample_gap_thresh=timedelta(minutes=15) 

def get_activity_fractions_from_duration(duration_dict):
    fraction_dict=dict()
    for day in duration_dict:
        fraction_dict[day]=dict()
        total_duration=timedelta(minutes=0)
        for activity in duration_dict[day]:
            total_duration+=duration_dict[day][activity]
        total_duration=total_duration.total_seconds()
        if total_duration> 0:
            for entry in duration_dict[day]:
                fraction_dict[day][entry]=duration_dict[day][entry].total_seconds()/total_duration
    return fraction_dict

def parse_motion_activity(file_path):    
    #read in the data
    dtype_dict=dict()
    dtype_dict['names']=('startTime',
                         'activityType',
                         'confidence')
    dtype_dict['formats']=(datetime,
                           'S36',
                           'i')
    data=np.loadtxt(file_path,
                    dtype=dtype_dict,
                    delimiter=',',
                    skiprows=1,
                    converters={0:lambda x: parse(x)})
    
    #get the duration of each activity by day 
    duration_dict=dict()
    fraction_dict=dict() 
    first_row=0
    try: 
        cur_time=data['startTime'][first_row]
        cur_day=data['startTime'][first_row].date() 
        cur_activity=data['activityType'][first_row]
        while cur_activity=="not available":
            first_row+=1
            cur_time=data['startTime'][first_row]
            cur_day=data['startTime'][first_row].date() 
            cur_activity=data['activityType'][first_row]
        for row in range(first_row+1,len(data)):
            new_activity=data['activityType'][row]
            new_time=data['startTime'][row]
            new_day=data['startTime'][row].date()
            if(new_time-cur_time)<=sample_gap_thresh:
                if new_activity=="not available":
                    #carry forward from the previous activity 
                    new_activity=cur_activity
                duration=new_time-cur_time
                if cur_day not in duration_dict:
                    duration_dict[cur_day]=dict()
                if cur_activity not in duration_dict[cur_day]:
                    duration_dict[cur_day][cur_activity]=duration
                else:
                    duration_dict[cur_day][cur_activity]+=duration
            cur_activity=new_activity
            cur_time=new_time
            cur_day=new_day
        #get the activity fractions relative to total duration
        fraction_dict=get_activity_fractions_from_duration(duration_dict)
        return [duration_dict,fraction_dict]
    except:
        print("skipping!:"+file_path) 
        return [duration_dict,fraction_dict]
        
def parse_healthkit_steps(file_path):
    #read in the data
    dtype_dict=dict()
    dtype_dict['names']=('startTime',
                         'endTime',
                         'type',
                         'value',
                         'unit',
                         'source',
                         'sourceIdentifier')
    dtype_dict['formats']=(datetime,
                           datetime,
                           'S36',
                           'i',
                           'S36',
                           'S36',
                           'S36')
    try:
        data=np.loadtxt(file_path,
                        dtype=dtype_dict,
                        delimiter=',',
                        skiprows=1,
                        converters={0:lambda x: parse(x),
                                    1:lambda x: parse(x)})
    except:
        print("COULD NOT PARSE:"+str(file_path))
        return {}
    #get the duration of each activity by day
    tally_dict=dict()
    try:
        for row in range(len(data)):
            day=data['startTime'][row].date()
            value=data['value'][row]
            datatype=data['type'][row]
            if day not in tally_dict:
                tally_dict[day]=dict()
            if datatype not in tally_dict[day]:
                tally_dict[day][datatype]=value
            else:
                tally_dict[day][datatype]+=value
        return tally_dict
    except:
        return tally_dict 
if __name__=="__main__":
    #TESTS for sherlock
    import pdb
    base_dir="/scratch/PI/euan/projects/mhc/data/synapseCache_v2/"
    #[motion_tracker_duration,motion_tracker_fractions]=parse_motion_activity(base_dir+"638/14145638/data-054aa9f4-cb94-4663-b3df-e98ef3421dcb.csv")
    health_kit_data=parse_healthkit_steps(base_dir+"661/13540661/data-cdf78ca9-1094-46ff-b7b4-94b75aafc7fb.csv")
    pdb.set_trace() 

    
