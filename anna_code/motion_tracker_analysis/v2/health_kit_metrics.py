def mean_step_count(data,outfname):
    metric_name='HKQuantityTypeIdentifierStepCount'
    return mean_metric(data,metric_name)

def mean_distance_walked(data,outfname):
    metric_name='HKQuantityTypeIdentifierDistanceWalk'
    return mean_metric(data,metric_name)
           
def mean_metric(data,metric_name):
    summary=dict()
    data_subset=data[np.where(data['Metric']==metric_name)]
    for row in range(len(data_subset)):
        cur_subject=data_subset[row]['Subject']
        cur_value=data_subset[row]['Value']
        if cur_subject not in summary:
            summary[cur_subject]=dict()
            summary[cur_subject][metric_name]=[cur_value]
        else:
            summary[cur_subject][metric_name].append(cur_value)
    for subject in summary:
        summary[subject][metric_name]=sum(summary[subject][metric_name])/len(summary[subject][metric_name])        
    return summary,[metric_name]

if __name__=="__main__":
    #TESTS ON SHERLOCK!
    from load_summaries import *
    import pdb
    filepath_healthkit="/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/health_kit_combined.txt"
    data_healthkit=load_health_kit_summary(filepath_healthkit)
    outfname="placeholder.txt"
    cur_mean_step_count=mean_step_count(data_healthkit,outfname)
    cur_mean_distance_walked=mean_distance_walked(data_healthkit,outfname)
    pdb.set_trace()
    
