#parses data tables
from table_loader import *
from synapse_parser import * 
import pdb
from os import listdir
from os.path import isfile, join

#we assume a subject will rarely have multiple table entries for motion tracker and health kit data in one day,
#but this is possible in the app, so we handle it: 
#sum minute durations together if there is a key conflict for a given day 
def merge_duration_dict(d1,d2):
    d3=dict()
    for entry in d1:
        d3[entry]=d1[entry]
    for entry in d2:
        if entry in d3:
            #sum by key
            for key in d2[entry]:
                if key in d3[entry]:
                    d3[entry][key]+=d2[entry][key]
                else:
                    d3[entry][key]=d2[entry][key]
        else:
            d3[entry]=d2[entry]
    return d3

#calculate average of fractions by day 
def merge_fraction_dict(d1,d2):
    d3=dict()
    for entry in d1:
        d3[entry]=d1[entry]
    for entry in d2:
        if entry in d3:
        #average by key
            for key in d2[entry]:
                if key in d3[entry]:
                    d3[entry][key]+=d2[entry][key]
                    d3[entry][key]=0.5*d3[entry][key]
                else:
                    d3[entry][key]=d2[entry][key]
        else:
            d3[entry]=d2[entry]
    return d3
    
def get_synapse_cache_entry(synapseCacheDir,blob_name):
    #print(str(blob_name)) 
    parent_dir=blob_name[-3::].lstrip('0')
    mypath=synapseCacheDir+parent_dir+"/"+blob_name
    onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]
    for f in onlyfiles:
        if f.startswith('data'):
            return mypath+'/'+f
        

def parse_motion_tracker_data(table_path,synapseCacheDir,subjects):
    data_table=load_motion_tracker(table_path)
    print("loaded motion tracker data table") 
    if subjects!="all": 
        subject_dict=dict()
        subjects=open(subjects,'r').read().strip().split('\n')
        for subject in subjects:
            subject_dict[subject]=1
    subject_duration_vals=dict()
    subject_fraction_vals=dict() 
    for row in range(len(data_table)):
        cur_subject=data_table['healthCode'][row]
        if (subjects!="all") and (cur_subject not in subject_dict):
            print("Skipping!") 
            continue
        else:
            print("Not skipping!") 
            blob_name=data_table['data'][row]
            synapseCacheFile=get_synapse_cache_entry(synapseCacheDir,blob_name)
            [motion_tracker_duration,motion_tracker_fractions]=parse_motion_activity(synapseCacheFile)
            if cur_subject not in subject_duration_vals:
                subject_duration_vals[cur_subject]=motion_tracker_duration
            else: 
                subject_duration_vals[cur_subject]=merge_duration_dict(subject_duration_vals[cur_subject],motion_tracker_duration)
            if cur_subject not in subject_fraction_vals:
                subject_fraction_vals[cur_subject]=motion_tracker_fractions
            else: 
                subject_fraction_vals[cur_subject]=merge_fraction_dict(subject_fraction_vals[cur_subject],motion_tracker_fractions)        
    return [subject_duration_vals,subject_fraction_vals]

def parse_healthkit_data_collector(table_path,synapseCacheDir,subjects):
    data_table=load_health_kit(table_path)
    if subjects !="all":
        subject_dict=dict()
        subjects=open(subjects,'r').read().strip().split('\n')
        for subject in subjects:
            subject_dict[subject]=1
    subject_distance_vals=dict()
    for row in range(len(data_table)):
        cur_subject=data_table['healthCode'][row] 
        if (subjects!="all") and (cur_subject not in subject_dict):
            continue
        else:
            blob_name=data_table['data'][row]
            synapseCacheFile=get_synapse_cache_entry(synapseCacheDir,blob_name)
            health_kit_distance=parse_healthkit_steps(synapseCacheFile)
            if cur_subject not in subject_distance_vals:
                subject_distance_vals[cur_subject]=health_kit_distance
            else: 
                subject_distance_vals[cur_subject]=merge_duration_dict(subject_distance_vals[cur_subject],health_kit_distance)
    return subject_distance_vals 
        


if __name__=="__main__":
    table_path="/scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-motionActivityCollector-v1.tsv"
    synapseCacheDir="/scratch/PI/euan/projects/mhc/data/synapseCache_v2/"
    subjects="subjects_for_test.txt"
    #subject_motion=parse_motion_tracker_data(table_path,synapseCacheDir,subjects)
    #subject_motion_duration=subject_motion[0]
    #subject_motion_fractions=subject_motion[1]
    table_path="/scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-HealthKitDataCollector-v1.tsv"
    subject_health_kit_distance=parse_healthkit_data_collector(table_path,synapseCacheDir,subjects) 
    pdb.set_trace()
    

