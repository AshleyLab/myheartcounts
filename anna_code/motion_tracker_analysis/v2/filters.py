from table_loader import *
from aggregators import get_day_index_to_intervention
import pdb 

def get_intervention(interventions,day_index):
    day_index_to_intervention=get_day_index_to_intervention(interventions)
    if day_index > max(day_index_to_intervention.keys()):
        return interventions[-1]
    else:
        return day_index_to_intervention[day_index]


#filter data to only include entries with a minimum number of datapoints
def min_datapoints(data,thresh):
    filtered=[data[0]]
    for line in data[1::]:
        tokens=line.split('\t')
        if int(tokens[-1])>=thresh:
            filtered.append(line)
    return filtered

#extract a specific field from the aggregate file (i.e steps or distance traveled) 
def extract_field(data,field):
    filtered=[data[0]]
    for line in data[1::]:
        tokens=line.split('\t')
        if(tokens[5]==field):
            filtered.append(line)
    return filtered

#i.e. assignment of activities 
def account_for_huge_gaps_in_time(data,ABmetadata):
    #read in the metadata file
    metadata=load_abtest(ABmetadata)
    metadata_dict=dict()
    for row in range(len(metadata)):
        subject=metadata['healthCode'][row]
        order=metadata['ABTestResultvariable_value'][row]
        metadata_dict[subject]=order.split(',')
    print('made metadata dictionary')
    subject_to_day_index=dict() 
    for line in data[1::]:
        tokens=line.split('\t')
        subject=tokens[0]
        day_index=int(tokens[3])
        if subject not in subject_to_day_index:
            subject_to_day_index[subject]=set([day_index])
        else:
            subject_to_day_index[subject].add(day_index)
    print("got subject list!")
    #assign old day index to new day index 
    remap_subject=dict()
    for subject in subject_to_day_index:
        indices=list(subject_to_day_index[subject])
        indices.sort()
        deltas=[indices[n]-indices[n-1] for n in range(1,len(indices))]
        #print(str(deltas))
        if ((len(deltas) > 0) and (max(deltas)>7)): 
            #check for a large gap 
            index_gap=deltas.index(max(deltas))
            if len(deltas[0:index_gap+1])<len(deltas[index_gap+1::]):
                #reset!
                new_start=indices[index_gap+1] 
                new_indices=[i-new_start for i in indices]
                remap_subject[subject]=dict()
                for l in range(len(indices)):
                    remap_subject[subject][indices[l]]=new_indices[l]
    print("remapped subjects with large gaps") 
    #re-generate the data file with day_index & intervention values swapped out
    adjusted_data=[data[0]]
    for line in data[1::]:
        tokens=line.split('\t')
        subject=tokens[0]
        if subject not in remap_subject:
            adjusted_data.append(line)
        else:
            cur_index=int(tokens[3]) 
            new_index=remap_subject[subject][cur_index]
            if new_index>=0:
                #keep!
                if subject not in metadata_dict:
                    if new_index<7:
                        updated_intervention="None"
                    else:
                        updated_intervention="NA"
                else:
                    updated_intervention=get_intervention(metadata_dict[subject],new_index)
                #replace day index and intervention label
                tokens[2]=updated_intervention
                tokens[3]=str(new_index)
                adjusted_data.append('\t'.join(tokens))
    print("updated data frame to remove indices that are likely invalid") 
    return adjusted_data

if __name__=="__main__":
    ## TESTS ###
    motion_data=open("/scratch/PI/euan/projects/mhc/data/timeseries_v2/motion_tracker_combined.txt",'r').read().strip().split('\n')
    min_filtered=min_datapoints(motion_data,100)
    gap_filtered=account_for_huge_gaps_in_time(min_filtered,"/scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-ABTestResults-v1.tsv")
    pdb.set_trace()
    #health_data=open("/scratch/PI/euan/projects/mhc/data/timeseries_v2/health_kit_combined.txt",'r').read().strip().split('\n')
