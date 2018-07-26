import sys 
from helpers import *
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse
from datetime import * 
from scipy.stats import mode 

#datadir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motionactivity/"
threshold=1000 # subject must have at least this number of data points each in the weekday & weekend categories to be included 
interval=60*2 # 2 minutes of data for interval majority vote 
timeout_thresh=60*15 # any data gap greater than 15 minutes is stationary 
ignoretz=True 
confidence_thresh=1 #ignore any entries with confidence value < threshold 
######################################################

#Determine whether subject has enough datapoints to be included in the analysis 
def includeSubject(filename_weekday,filename_weekend,threshold): 
    #print "checking include..." + str(filename_weekday) 
    data_weekday=len(open(filename_weekday,'r').read().split('\n'))
    data_weekend=len(open(filename_weekend,'r').read().split('\n')) 
    if (data_weekday>threshold) and (data_weekend>threshold): 
        return True 
    else: 
        return False

#split the data into 2 minute windows, and take the majority vote for the activity performed in each window 
def window(data,interval,timeout_thresh,activity_index): 
    #print "windowing..." 
    confidence_index=activity_index+1 
    start_times=[] 
    end_times=[] 
    activities=[] 
    numentries=0 
    duration=0 #records data ignoring gaps > threshold 
    if len(data)<2: 
        raise Exception("This subject does not have at least"+str(threshold) +"datapoints, should have been excluded from the analysis by the \"includeSubject\" function!") 
    #get the first window of data 
    first_entry=data[0].split('\t') 
    second_entry=data[1].split('\t') 
    first_time=parse(first_entry[0],ignoretz=ignoretz) 
    first_activity=first_entry[activity_index] 
    second_time=parse(second_entry[0],ignoretz=ignoretz) 
    second_activity=second_entry[activity_index] 
    cur_window=[first_time,second_time] 
    cur_activities=[first_activity,second_activity] 
    #iterate through the timepoints, taking a 2 minute sliding window 
    for i in range(2,len(data)): 
        #get the next entry 
        entry=data[i].split('\t') 
        if int(entry[confidence_index])<confidence_threshold: 
            continue #ignore the low-confidence entry 
        numentries+=1 
        new_time=parse(entry[0],ignoretz=ignoretz) 
        new_activity=entry[activity_index] 
        #first, check to see if we have a gap > 15 minutes between the previous entry and this new entry 
        if (new_time-cur_window[1]).total_seconds() > timeout_thresh: 
            #put an end to the previous window. 
            start_times.append(cur_window[0]) 
            end_times.append(cur_window[1]) 
            #print str(mode(cur_activities)) 
            activities.append(mode(cur_activities).mode[0])  
            #treat the gap between new_time and cur_window[1] as a stationary state 
            if (new_time-cur_window[1]).total_seconds()<12*60*60: 
                #if there are more than 12 hours missing, this is a new day of data! don't count the gap 
                start_times.append(cur_window[1])
                end_times.append(new_time) 
                activities.append('1') #'1' means stationary  
            #reset the current window to begin at the new_time timepoint 
            cur_window=[new_time,new_time]
            cur_activities=[new_activity] 
        elif (cur_window[1]-cur_window[0]).total_seconds() < interval: 
            #we don't have 2 minutes of data yet, add in the new entry 
            cur_window[1]=new_time 
            cur_activities.append(new_activity) 
        else: 
            #end the previous interval and begin a new one! 
            start_times.append(cur_window[0]) 
            end_times.append(cur_window[1]) 
            #print str(mode(cur_activities)) 
            activities.append(mode(cur_activities).mode[0])  
            cur_window=[cur_window[1],new_time] 
            cur_activities=[new_activity]
    #add the final data window that we have not closed yet
    start_times.append(cur_window[0]) 
    end_times.append(cur_window[1]) 
    #print str(mode(cur_activities)) 
    activities.append(mode(cur_activities).mode[0])  
    return start_times,end_times,activities,numentries 

#computes the fraction of time spent doing each activity 
def get_fractions(starttimes,endtimes,activities): 
    total_time=timedelta(seconds=0)
    fractions=dict() 
    for i in range(len(starttimes)): 
        cur_start=starttimes[i] 
        cur_end=endtimes[i] 
        cur_activity=activities[i] 
        if cur_activity not in fractions: 
            fractions[cur_activity]=(cur_end-cur_start)
        else: 
            fractions[cur_activity]+=(cur_end-cur_start) 
        total_time+=(cur_end-cur_start)
    #divide by total_time to get fractions 
    total_time=total_time.total_seconds()*1.0 
    for activity in fractions: 
        fractions[activity]=fractions[activity].total_seconds()/total_time 
    return fractions 

#process data without splitting it into weekday & weekend labels 
def process_subject_combined(filename1,filename2): 
    data1=split_lines(filename1) 
    data1.sort() 
    #some types of data have activity in column 2 (0-indexed), and some in column 1(0 -indexed) , find out which one this is by looking at the first line 
    #process data1
    firstline=data1[0].split('\t') 
    if len(firstline)==3: 
        activity_index=1 
    else: 
        activity_index=2 
    data_windowed_starttimes1, data_windowed_endtimes1,data_windowed_activities1,numentries1=window(data1,interval,timeout_thresh,activity_index)
    #process data2
    data2=split_lines(filename2) 
    data2.sort() 
    firstline=data2[0].split('\t') 
    if len(firstline)==3: 
        activity_index=1 
    else: 
        activity_index=2 
    data_windowed_starttimes2, data_windowed_endtimes2,data_windowed_activities2,numentries2=window(data1,interval,timeout_thresh,activity_index)
    
    #get the total fraction of each activity 
    numentries_total=numentries1+numentries2
    data_windowed_starttimes=data_windowed_starttimes1+data_windowed_starttimes2 
    data_windowed_endtimes=data_windowed_endtimes1+data_windowed_endtimes2 
    data_windowed_activities=data_windowed_activities1+data_windowed_activities2 
    duration_total=sum([(data_windowed_endtimes[i]-data_windowed_starttimes[i]).total_seconds() for i in range(len(data_windowed_endtimes))])#Todo: Do we need to convert this to seconds? 
    activity_fractions=get_fractions(data_windowed_starttimes, data_windowed_endtimes,data_windowed_activities)
    return activity_fractions,duration_total,numentries_total 



def process_subject(filename): 
    data=split_lines(filename) 
    data.sort() 
    #some types of data have activity in column 2 (0-indexed), and some in column 1(0 -indexed) , find out which one this is by looking at the first line 
    firstline=data[0].split('\t') 
    if len(firstline)==3: 
        activity_index=1 
    else: 
        activity_index=2 
    data_windowed_starttimes, data_windowed_endtimes,data_windowed_activities,numentries=window(data,interval,timeout_thresh,activity_index)
    activity_fractions=get_fractions(data_windowed_starttimes,data_windowed_endtimes,data_windowed_activities) 
    duration=sum([(data_windowed_endtimes[i]-data_windowed_starttimes[i]).total_seconds() for i in range(len(data_windowed_starttimes))])
    return activity_fractions,duration,numentries 

def main():
    start_index=int(sys.argv[1]) 
    end_index=int(sys.argv[2]) 

    datadir_weekday="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/weekday/"
    datadir_weekend="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/weekend/"
    activity_names=dict() 
    activity_names['0']="unknown"
    activity_names['1']='stationary'
    activity_names['2']='walking'
    activity_names['3']='running' 
    activity_names['4']='automotive'
    activity_names['5']='cycling' 
    activities=activity_names.keys() 

    full_dict=dict() # one entry per subject 
    onlyfiles_weekday = [ f for f in listdir(datadir_weekday) if isfile(join(datadir_weekday,f))]
    onlyfiles_weekend = [ f for f in listdir(datadir_weekend) if isfile(join(datadir_weekend,f))]
    #get the subjects that have sufficient data to be included in the analysis 
    total_subjects=len(onlyfiles_weekday) 
    j=-1
    for f in onlyfiles_weekday[start_index:min(end_index,len(onlyfiles_weekday))]: 
        j+=1
        print str(j) 
        include=includeSubject(datadir_weekday+f,datadir_weekend+f,threshold)
        if include==False: 
            continue 
        weekday_fractions,weekday_duration,weekday_numentries=process_subject(datadir_weekday+f)
        weekend_fractions,weekend_duration,weekend_numentries=process_subject(datadir_weekend+f)
        total_fractions,total_duration,total_numentries=process_subject_combined(datadir_weekend+f,datadir_weekday+f) 

        subject=f.split('.')[0] 
        full_dict[subject]=dict() 
        for activity in activity_names: 
            full_dict[subject][activity]=dict() 
            if activity in weekday_fractions: 
                full_dict[subject][activity]['weekday']=weekday_fractions[activity] 
            else: 
                full_dict[subject][activity]['weekday']=0 
            if activity in weekend_fractions: 
                full_dict[subject][activity]['weekend']=weekend_fractions[activity] 
            else: 
                full_dict[subject][activity]['weekend']=0 
            if activity in total_fractions: 
                full_dict[subject][activity]['total']=total_fractions[activity] 
            else: 
                full_dict[subject][activity]['total']=0 
        full_dict[subject]['duration']=[weekday_duration,weekend_duration,total_duration]  
        full_dict[subject]['numentries']=[weekday_numentries,weekend_numentries,total_numentries] 

    #generate output file 
    outf=open('fractions.txt.'+str(start_index)+'.'+str(end_index),'w') 
    entries=activity_names.items() 
    activity_codes=[i[0] for i in entries] 
    activity_names=[i[1] for i in entries] 
    outf.write('Subject') 
    for activity_name in activity_names: 
        outf.write('\t'+activity_name+"Weekday"+'\t'+activity_name+"Weekend"+'\t'+activity_name+"Total"+'\t')
    outf.write('Duration\tTotalEntries\n') 
    for subject in full_dict:
        outf.write(subject) 
        for activity in activity_codes: 
            outf.write('\t'+str(full_dict[subject][activity]['weekday'])+'\t'+str(full_dict[subject][activity]['weekend'])+'\t'+str(full_dict[subject][activity]['total']))
        outf.write('\t'+str(full_dict[subject]['duration'][2])+'\t'+str(full_dict[subject]['numentries'][2]))
        outf.write('\n')

if __name__=="__main__":
    main() 

