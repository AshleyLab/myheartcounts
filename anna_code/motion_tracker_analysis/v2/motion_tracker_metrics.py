import numpy as np 
def get_features_for_clustering(data):
    #percent of time spent in each state on weekdays & weekends
    summary=dict()
    total_weekday=dict() #total minutes per subject (denominator for average)
    total_weekend=dict()
    total=dict() 
    activities=set([])
    for row in range(len(data)):
        cur_subject=data['Subject'][row]
        cur_day=data['DayType'][row]
        if cur_day < 5:
            cur_day="weekday"
        else:
            cur_day="weekend" 
        cur_activity=data['Activity'][row]
        cur_duration=data['Duration_in_Minutes'][row]
        if cur_day=="weekend":
            if cur_subject not in total_weekend:
                total_weekend[cur_subject]=cur_duration*1.0
            else:
                total_weekend[cur_subject]+=cur_duration
        else:
            if cur_subject not in total_weekday:
                total_weekday[cur_subject]=cur_duration*1.0
            else:
                total_weekday[cur_subject]+=cur_duration
        if cur_subject not in total:
            total[cur_subject]=cur_duration*1.0
        else:
            total[cur_subject]+=cur_duration
        
        if cur_subject not in summary:
            summary[cur_subject]=dict() 
        key1=cur_day+"_"+cur_activity
        key2=cur_activity
        activities.add(key1)
        activities.add(key2)
        
        if key1 not in summary[cur_subject]:
            summary[cur_subject][key1]=cur_duration*1.0
        else:
            summary[cur_subject][key1]+=cur_duration
        if key2 not in summary[cur_subject]:
            summary[cur_subject][key2]=cur_duration*1.0
        else:
            summary[cur_subject][key2]+=cur_duration
    #get fractional values
    for subject in summary:
        for activity in summary[subject]:
            if activity.startswith('weekday'):
                summary[subject][activity]=summary[subject][activity]/total_weekday[subject]
            elif activity.startswith('weekend'):
                summary[subject][activity]=summary[subject][activity]/total_weekend[subject]
            else:
                summary[subject][activity]=summary[subject][activity]/total[subject]
    #generate the output file
    outf=open('tmp','w')
    activities=list(activities)
    outf.write('Subject\t'+'\t'.join(activities)+'\n')
    subjects=summary.keys() 
    for subject in subjects:
        outf.write(subject)
        for activity in activities:
            if activity in summary[subject]:
                outf.write('\t'+str(summary[subject][activity]))
            else:
                outf.write('\t0')
                summary[subject][activity]=0
        outf.write('\n') 
    return summary,activities,subjects

def kmeans_cluster(data):
    summary,activities,subjects=get_features_for_clustering(data)
    features=np.genfromtxt('tmp',usecols=range(1,len(activities)+1),skip_header=True)
    from sklearn.cluster import KMeans
    kmeans=KMeans(n_clusters=10,random_state=0).fit(features)
    labels=kmeans.labels_
    for i in range(len(labels)):
        cur_subject=subjects[i]
        cur_label=labels[i]
        summary[cur_subject]['cluster']=cur_label
    return summary,activities+['cluster']
    
    
def percent_of_time_active(data):
    active_states=['walking','running','cycling']
    summary=dict()
    total=dict() 
    for row in range(len(data)):
        cur_subject=data['Subject'][row]
        cur_activity=data['Activity'][row]
        cur_duration=data['Duration_in_Minutes'][row]
        if cur_subject not in total:
            total[cur_subject]=cur_duration*1.0
        else:
            total[cur_subject]+=cur_duration        
        if cur_subject not in summary:
            summary[cur_subject]=dict()
            summary[cur_subject]['percent_active']=0
        if cur_activity in active_states:
            summary[cur_subject]['percent_active']+=cur_duration
    #get fractional values
    for subject in summary:
        summary[subject]['percent_active']=summary[subject]['percent_active']/total[subject]
    return summary,['percent_active']

def percent_of_time_stationary(data):
    summary=dict()
    total=dict() 
    for row in range(len(data)):
        cur_subject=data['Subject'][row]
        cur_activity=data['Activity'][row]
        cur_duration=data['Duration_in_Minutes'][row]
        if cur_subject not in total:
            total[cur_subject]=cur_duration*1.0
        else:
            total[cur_subject]+=cur_duration        
        if cur_subject not in summary:
            summary[cur_subject]=dict()
            summary[cur_subject]['percent_stationary']=0
        if cur_activity =="stationary":
            summary[cur_subject]['percent_stationary']+=cur_duration
    #get fractional values
    for subject in summary:
        summary[subject]['percent_stationary']=summary[subject]['percent_stationary']/total[subject]
    return summary,['percent_stationary']

if __name__=="__main__":
    #TESTS ON SHERLOCK
    import pdb
    from load_summaries import * 
    filepath_motiontracker="/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/motion_tracker_combined.filered.txt"
    data_motiontracker=load_motion_tracker_summary(filepath_motiontracker)
    summary1=kmeans_cluster(data_motiontracker)
    summary2=percent_of_time_active(data_motiontracker)
    summary3=percent_of_time_stationary(data_motiontracker)
    pdb.set_trace() 
