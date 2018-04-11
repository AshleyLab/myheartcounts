from table_loader import *
from aggregators import get_day_index_to_intervention
import pdb 

def get_intervention(interventions,day_index):
    day_index_to_intervention=get_day_index_to_intervention(interventions)
    if day_index > max(day_index_to_intervention.keys()):
        return interventions[-1]
    else:
        return day_index_to_intervention[day_index]


#filter data to only include entries with a minimum number of datapoints and a minimum duration of time 
#also specify max allowed duration of time. 
def min_datapoints(data,min_thresh,min_minutes,max_minutes):
    filtered=[data[0]]
    for line in data[1::]:
        tokens=line.split('\t')
        if int(tokens[-2])>=min_thresh:
            if float(tokens[5])>=min_minutes: 
                if float(tokens[5])<=max_minutes: 
                    filtered.append(line)
    return filtered

#filter to only include data sources that contain the specified "source" string in their name. 
def extract_source(data,source): 
    filtered=data[0] 
    for line in data[1::]: 
        tokens=line.split('\t') 
        if len(tokens)<7: 
            print(str(tokens)) 
            continue 
        if(tokens[6].__contains__(source)): 
            filtered.append(line)
    return filtered 


#extract a specific field from the aggregate file (i.e steps or distance traveled) 
def extract_field(data,field):
    filtered=[data[0]]
    for line in data[1::]:
        tokens=line.split('\t')
        if len(tokens)<6:
            print(str(tokens))
            continue
        if(tokens[5]==field):
            filtered.append(line)
    return filtered


if __name__=="__main__":
    ## TESTS ###
    motion_data=open("/scratch/PI/euan/projects/mhc/data/timeseries_v2/motion_tracker_combined.txt",'r').read().strip().split('\n')
    min_filtered=min_datapoints(motion_data,100)
    pdb.set_trace()
    #health_data=open("/scratch/PI/euan/projects/mhc/data/timeseries_v2/health_kit_combined.txt",'r').read().strip().split('\n')
