#NOTE: tested on pythoon 3.6 w/ anaconda 3
#Author: annashch@stanford.edu
import numpy as np
from datetime import datetime,timedelta,date
from dateutil.parser import parse
import pdb 
sample_gap_thresh=timedelta(minutes=15) 
min_allowed_time=date(2015,1,1)
max_allowed_time=date(2018,5,5) 

#perform qc on healthkit entries to ensure they fall into humanly feasible ranges 
def qc_mt(data): 
    num_rows=data.shape[0]
    to_delete=[] 
    for row_index in range(num_rows): 
        cur_date=data[row_index]['startTime'].date()
        if ((cur_date < min_allowed_time) or (cur_date > max_allowed_time)): 
            to_delete.append(row_index)
    print(str(to_delete))
    data=np.delete(data,to_delete)        
    return data    
def qc_hk(datatype,value,startTime,endTime):
    datatype=datatype.decode('utf-8') 
    if datatype not in ["HKQuantityTypeIdentifierDistanceWalk","HKQuantityTypeIdentifierStepCount"]:
        return True 
    if datatype=="HKQuantityTypeIdentifierDistanceWalk": 
        time_diff=(endTime-startTime).total_seconds()/60.0
        speed=value/time_diff
        if speed > 750: 
            print('BAD SPEED') 
            return False 
        else: 
            return True 
    if datatype=="HKQuantityTypeIdentifierStepCount": 
        time_diff=(endTime-startTime).total_seconds()/60.0 
        rate=value/time_diff 
        if rate >1000: 
            print("BAD RATE") 
            return False 
        else: 
            return True 

def get_activity_fractions_from_duration(duration_dict):
    fraction_dict=dict()
    for day in duration_dict:
        fraction_dict[day]=dict()
        total_duration=timedelta(minutes=0)
        for activity in duration_dict[day]:
            for blob in duration_dict[day][activity]: 
                total_duration+=abs(duration_dict[day][activity][blob])
        total_duration=total_duration.total_seconds()
        if total_duration > 0:
            for entry in duration_dict[day]:
                fraction_dict[day][entry]=dict() 
                for blob in duration_dict[day][entry]:
                    fraction_dict[day][entry][blob]=duration_dict[day][entry][blob].total_seconds()/total_duration
    return fraction_dict

def parse_motion_activity(file_path):
    duration_dict=dict()
    fraction_dict=dict()
    numentries=dict() 
    #read in the data
    dtype_dict=dict()
    dtype_dict['names']=('startTime',
                         'activityType',
                         'confidence')
    dtype_dict['formats']=(datetime,
                           'U36',
                           'i')
    try:
        cur_blob=file_path.split('/')[-2]
        data=np.genfromtxt(file_path,
                           dtype=dtype_dict['formats'],
                           names=dtype_dict['names'],
                           delimiter=',',
                           skip_header=True,
                           loose=True,
                           invalid_raise=False,
                           converters={0:lambda x: parse(x)})
        data=np.unique(data)
        data=qc_mt(data) 
    except:
        return [duration_dict,fraction_dict,numentries]
    
    #get the duration of each activity by day 
    first_row=0
    try:
        num_rows=len(data)
        cur_time=data['startTime'][first_row]
        cur_day=data['startTime'][first_row].date() 
        cur_activity=data['activityType'][first_row]
        while (cur_activity=="not available") and (first_row <(num_rows-1)):
            first_row+=1
            cur_time=data['startTime'][first_row]
            cur_day=data['startTime'][first_row].date() 
            cur_activity=data['activityType'][first_row]
    except:
        return[duration_dict,fraction_dict,numentries]

    for row in range(first_row+1,len(data)):
        try:
            new_activity=data['activityType'][row]
            new_time=data['startTime'][row]
            new_day=data['startTime'][row].date()
            if(new_time-cur_time)<=sample_gap_thresh:
                if new_activity=="not available":
                    #carry forward from the previous activity 
                    new_activity=cur_activity
                duration=abs(new_time-cur_time)
                if cur_day not in duration_dict:
                    duration_dict[cur_day]=dict()
                    numentries[cur_day]=0
                if cur_activity not in duration_dict[cur_day]:
                    duration_dict[cur_day][cur_activity]=dict() 
                if cur_blob not in duration_dict[cur_day][cur_activity]: 
                    duration_dict[cur_day][cur_activity][cur_blob]=duration 
                else:
                    duration_dict[cur_day][cur_activity][cur_blob]+=duration
                numentries[cur_day]+=1  
            cur_activity=new_activity
            cur_time=new_time
            cur_day=new_day
        except:
            continue
    #get the activity fractions relative to total duration
    fraction_dict=get_activity_fractions_from_duration(duration_dict)
    return [duration_dict,fraction_dict,numentries]
        
def parse_healthkit_steps(file_path):
    tally_dict=dict()
    #keep track of the blob that yielded this data 
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
                           'f',
                           'S36',
                           'S36',
                           'S36')
    try:
        cur_blob=file_path.split('/')[-2]
        data=np.genfromtxt(file_path,
                           dtype=dtype_dict['formats'],
                           names=dtype_dict['names'],
                           delimiter=',',
                           skip_header=True,
                           loose=True,
                           invalid_raise=False,
                           converters={0:lambda x: parse(x),
                                       1:lambda x: parse(x)})
        try:
            data=np.unique(data)
        except: 
            data=np.unique(data[1::])
    except:
        print("There was a problem importing:"+str(file_path))
        return tally_dict
    #get the duration of each activity by day
    try:
        if ((data is not None) and (data.size>0)):
            if(data.size==1): 
                datatype=data['type'].tolist() 
                source=str(data['source'])
                sourceIdentifier=str(data['sourceIdentifier'])
                source_tuple=tuple([source,sourceIdentifier])
                value=data['value'].tolist()
                day=data['startTime'].tolist().date()
                #check if the value makes sense
                pdb.set_trace() 
                qc_result=qc_hk(datatype,value,data['startTime'],data['endTime'])
                if qc_result==True: 
                    if day not in tally_dict:
                        tally_dict[day]=dict()                
                    if datatype not in tally_dict[day]:
                        tally_dict[day][datatype]=dict()
                    if source_tuple not in tally_dict[day][datatype]:
                        tally_dict[day][datatype][source_tuple]=dict() 
                    if cur_blob not in tally_dict[day][datatype][source_tuple]: 
                        tally_dict[day][datatype][source_tuple][cur_blob]=value 
                    else:
                        tally_dict[day][datatype][source_tuple][cur_blob]+=value
            else:
                for row in range(data.size):
                    if data['startTime'][row] is not None:
                        datatype=data['type'][row]
                        source=data['source'][row]
                        sourceIdentifier=data['sourceIdentifier'][row]
                        source_tuple=tuple([source,sourceIdentifier])
                        day=data['startTime'][row].date()
                        value=data['value'][row]
                        qc_result=qc_hk(datatype,value,data['startTime'][row],data['endTime'][row])
                        if qc_result==False: 
                            continue 
                        if day not in tally_dict:
                            tally_dict[day]=dict()
                        if datatype not in tally_dict[day]:
                            tally_dict[day][datatype]=dict()
                        if source_tuple not in tally_dict[day][datatype]:
                            tally_dict[day][datatype][source_tuple]=dict() 
                        if cur_blob not in tally_dict[day][datatype][source_tuple]:
                            tally_dict[day][datatype][source_tuple][cur_blob]=value
                        else:
                            tally_dict[day][datatype][source_tuple][cur_blob]+=value
    except:
        print("There was a problem importing:"+str(file_path))
    return tally_dict

if __name__=="__main__":
    #TESTS for sherlock
    import pdb
    base_dir="/scratch/PI/euan/projects/mhc/data/synapseCache/"
    #[motion_tracker_duration,motion_tracker_fractions,num_entries]=parse_motion_activity(base_dir+"927/16760927/data-a3201e39-7e45-486c-8a19-43f19174fb45.csv")
    health_kit_data=parse_healthkit_steps('/scratch/PI/euan/projects/mhc/data/synapseCache/321/16862321/data-d06f43a8-ea7d-4c96-8022-375c296c312d.csv')
    pdb.set_trace() 

    
