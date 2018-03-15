#parses data tables
from table_loader import *
from synapse_parser import *
from datetime import datetime,timedelta
import pdb
from os import listdir
from os.path import isfile, join
import warnings
warnings.filterwarnings("ignore")

#we assume a subject will rarely have multiple table entries for motion tracker and health kit data in one day,
#but this is possible in the app, so we handle it: 
#sum minute durations together if there is a key conflict for a given day 
def merge_duration_dict(d1,d2):
    #merge duration values 
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
    #update fraction values
    d_total=dict()
    for entry in d3:
        d_total[entry]=timedelta(seconds=0)
        for key in d3[entry]:
            d_total[entry]+=d3[entry][key]
    d_fract=dict()
    for entry in d3:
        d_fract[entry]=dict()
        for key in d3[entry]:
            if d_total[entry].total_seconds()==0:
                d_fract[entry][key]=0
            else: 
                d_fract[entry][key]=d3[entry][key].total_seconds()/d_total[entry].total_seconds()
    return d3,d_fract


def merge_numentries_dict(d1,d2):
    d3=dict()
    for entry in d1:
        d3[entry]=d1[entry]
    for entry in d2:
        if entry in d3:
            d3[entry]=d3[entry]+d2[entry]
        else:
            d3[entry]=d2[entry]
    return d3
def merge_numentries_dict_healthkit(d1,d2):
    d3=dict()
    for day in d1:
        d3[day]=d1[day]
    for day in d2:
        if day not in d3:
            d3[day]=d2[day]
        for datatype in d2[day]: 
            if datatype not in d3[day]:
                d3[day][datatype]=d2[day][datatype]
            for source_tuple in d2[day][datatype]: 
                if source_tuple not in d3[day][datatype]:
                    d3[day][datatype][source_tuple]=d2[day][datatype][source_tuple]
                else:
                    d3[day][datatype][source_tuple]+=d2[day][datatype][source_tuple]
    return d3

def get_synapse_cache_entry(synapseCacheDir,blob_name):
    #print(str(blob_name)) 
    parent_dir=blob_name[-3::].lstrip('0')
    if parent_dir=="":
        parent_dir="0" 
    mypath=synapseCacheDir+parent_dir+"/"+blob_name
    try:
        onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]
        onlyfiles=[f for f in onlyfiles if f.startswith('data')]
        #first, check if there are any filtered files. 
        priority=[f for f in onlyfiles if f.endswith('filtered')]
        if len(priority)>0: 
            return mypath+'/'+priority[0] 
        #only return a single file in case there are copies (i.e. multiple data pulls of the same file seem to create copies) 
        return mypath+'/'+onlyfiles[0]        
    except: 
        return None

def parse_motion_tracker(table_path,synapseCacheDir,subjects):
    data_table=load_motion_tracker(table_path)
    print("loaded motion tracker data table") 
    if subjects!="all": 
        subject_dict=dict()
        subjects=open(subjects,'r').read().strip().split('\n')
        for subject in subjects:
            subject_dict[subject]=1
    subject_duration_vals=dict()
    subject_fraction_vals=dict()
    subject_numentries=dict()
    
    total_rows=len(data_table)
    for row in range(total_rows):
        if row%100==0:
            print(str(row)+"/"+str(total_rows))
        cur_subject=data_table['healthCode'][row]
        if (subjects!="all") and (cur_subject not in subject_dict):
            #print("Skipping!") 
            continue
        else:
            #print("Not skipping!") 
            blob_name=data_table['data'][row]
            if blob_name.endswith('NA'):
                continue 
            synapseCacheFile=get_synapse_cache_entry(synapseCacheDir,blob_name)
            [motion_tracker_duration,motion_tracker_fractions,numentries]=parse_motion_activity(synapseCacheFile)
            if cur_subject not in subject_duration_vals:
                subject_duration_vals[cur_subject]=motion_tracker_duration
                subject_fraction_vals[cur_subject]=motion_tracker_fractions
            else:
                [merged_duration,merged_fractions]=merge_duration_dict(subject_duration_vals[cur_subject],motion_tracker_duration)
                subject_duration_vals[cur_subject]=merged_duration
                subject_fraction_vals[cur_subject]=merged_fractions
            if cur_subject not in subject_numentries:
                subject_numentries[cur_subject]=numentries
            else:
                subject_numentries[cur_subject]=merge_numentries_dict(subject_numentries[cur_subject],numentries)
                
    return [subject_duration_vals,subject_fraction_vals,subject_numentries]

def parse_healthkit_data_collector(table_path,synapseCacheDir,subjects):
    data_table=load_health_kit(table_path)
    print("loaded healthkit data table") 
    if subjects !="all":
        subject_dict=dict()
        subjects=open(subjects,'r').read().strip().split('\n')
        for subject in subjects:
            subject_dict[subject]=1
    subject_distance_vals=dict()
    total_rows=len(data_table)
    print(str(total_rows))
    #record_matches=0 
    #print("total_rows:"+str(total_rows))
    for row in range(total_rows):
        #if row%100==0:
        #    print(str(row)+"/"+str(total_rows))
        cur_subject=data_table['healthCode'][row] 
        if (subjects!="all") and (cur_subject not in subject_dict):
            continue
        else:
            #record_matches+=1
            #print(str(record_matches))
            blob_name=data_table['data'][row]
            if blob_name.endswith("NA"):
                continue
            if blob_name.endswith('None'): 
                continue 
            synapseCacheFile=get_synapse_cache_entry(synapseCacheDir,blob_name)
            #print(synapseCacheFile)
            #print("got blob:"+str(blob_name))
            health_kit_distance=parse_healthkit_steps(synapseCacheFile)
            if cur_subject not in subject_distance_vals:
                subject_distance_vals[cur_subject]=health_kit_distance
            else:
                subject_distance_vals[cur_subject]=merge_numentries_dict_healthkit(subject_distance_vals[cur_subject],health_kit_distance)
    return subject_distance_vals 
        


if __name__=="__main__":
    #TESTS 
    #table_path="/scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-motionActivityCollector-v1.tsv"
    synapseCacheDir="/scratch/PI/euan/projects/mhc/data/synapseCache/"
    subjects="subjects_for_test.txt"
    #subject_motion=parse_motion_tracker(table_path,synapseCacheDir,subjects)
    #subject_motion_duration=subject_motion[0]
    #subject_motion_fractions=subject_motion[1]
    #subject_motion_numentries=subject_motion[2]
    
    table_path="/scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-HealthKitDataCollector-v1.tsv"
    subject_health_kit_distance=parse_healthkit_data_collector(table_path,synapseCacheDir,subjects) 
    pdb.set_trace()
    

