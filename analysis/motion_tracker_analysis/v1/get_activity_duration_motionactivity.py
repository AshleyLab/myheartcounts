import sys 
from helpers import *
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse
from datetime import * 
#datadir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motionactivity/"
datadir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/weekday/"
activity_names=dict() 
activity_names['0']="unknown"
activity_names['1']='stationary'
activity_names['2']='walking'
activity_names['3']='running' 
activity_names['4']='automotive'
activity_names['5']='cycling' 

######################################################

def main():
    print "datadir:"+str(datadir) 
    #onlyfiles = [ f for f in listdir(datadir) if isfile(join(datadir,f)) ]
    data=split_lines(datadir+"e20da26f-b708-43b2-9787-4f5a0b5785ab.tsv")
    #print str(subject)
    duration_dict=dict()
    gap_dict=dict() 
    instance_dict=dict() 
    cur_activity=None 
    cur_time=None
    overall_gap=[timedelta(seconds=1),0,0] 
    for line in data: 
        tokens=line.split('\t') 
        datetime=parse(tokens[0]) 
        activity=tokens[2] 
        if activity not in duration_dict: 
            duration_dict[activity]=timedelta(seconds=1)  
        if activity not in gap_dict: 
            gap_dict[activity]=[timedelta(seconds=1),0,0] 
        if activity not in instance_dict: 
            instance_dict[activity]=1 
        else: 
            instance_dict[activity]+=1 
        if cur_activity==None: 
            cur_activity=activity 
            cur_time=datetime 
            firsttime=datetime 
            continue 
        lasttime=datetime 
        if activity==cur_activity:
            duration=datetime-cur_time 
            duration_dict[activity]+=duration 
            if duration > gap_dict[activity][0]: 
                gap_dict[activity]=[duration,cur_time,datetime]
            if duration > overall_gap[0]: 
                overall_gap=[duration,cur_time,datetime] 
        cur_time=datetime 
        cur_activity=activity
    print "overall gap:"+str(overall_gap[0].total_seconds()/3600.0) 
    print "durations:"
    for entry in duration_dict: 
        print str(activity_names[entry])+'\t'+str(duration_dict[entry].total_seconds()/3600.0)
    print "instances:"
    for entry in instance_dict: 
        print str(activity_names[entry])+'\t'+str(instance_dict[entry])
    print "gaps:"
    for entry in gap_dict: 
        print str(activity_names[entry])+'\t'+str(gap_dict[entry][0].total_seconds()/3600.0)+'\t'+str(gap_dict[entry][1])+'\t'+str(gap_dict[entry][2]) 
    print "total : "+str((lasttime-firsttime).total_seconds()/3600.0)
    print str(firsttime) 
    print str(lasttime) 
if __name__=="__main__":
    main() 

