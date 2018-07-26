import sys 
from helpers import *
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse
from datetime import * 
#datadir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motionactivity/"
######################################################

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
    onlyfiles_weekday=[datadir_weekday+f for f in onlyfiles_weekday] 
    onlyfiles_weekend=[datadir_weekend+f for f in onlyfiles_weekend] 
    onlyfiles=onlyfiles_weekday+onlyfiles_weekend 
    c=0 
    totalfiles=str(len(onlyfiles)) 
    for f in onlyfiles[start_index:min(end_index,len(onlyfiles))]: 
        c+=1
        data=split_lines(f) 
        subject=f.split('.')[0].split('/')[-1] 
        print str(subject) +" "+str(c)+"/"+totalfiles
        if subject not in full_dict: 
            full_dict[subject]=dict() 
            full_dict[subject]['duration']=dict() 
            full_dict[subject]['gap']=dict() 
            full_dict[subject]['instance']=dict() 
            full_dict[subject]['fraction']=dict() 
            full_dict[subject]['totalduration']=timedelta(seconds=0)
            for activity in activities: 
                full_dict[subject]['duration'][activity]=timedelta(seconds=0) 
                full_dict[subject]['gap'][activity]=[timedelta(seconds=0),0,0] 
                full_dict[subject]['instance'][activity]=0 
                full_dict[subject]['fraction'][activity]=[0,0] 
        cur_activity=None 
        cur_time=None
        total_time=timedelta(seconds=0)
        for line in data: 
            tokens=line.split('\t') 
            datetime=parse(tokens[0]) 
            activity=tokens[2] 
            full_dict[subject]['instance'][activity]+=1
            if cur_activity==None: 
                cur_activity=activity 
                cur_time=datetime 
                continue
            duration=datetime-cur_time 
            if duration <timedelta(seconds=0): 
                continue 
            total_time+=duration 
            if activity==cur_activity:
                full_dict[subject]['duration'][activity]+=duration 
                if duration > full_dict[subject]['gap'][activity][0]:
                    full_dict[subject]['gap'][activity]=[duration,cur_time,datetime]
            cur_time=datetime 
            cur_activity=activity            
        #get the denominator; out of all activity and out of 48 period 
        full_dict[subject]['totalduration']+=total_time 
    for subject in full_dict: 
        for activity in activity_names: 
            subject_duration=full_dict[subject]['totalduration'].total_seconds() 
            activity_duration=full_dict[subject]['duration'][activity].total_seconds()  
            full_dict[subject]['fraction'][activity]=[activity_duration*1.0/subject_duration,activity_duration/(48.0*3600)]
    #generate output file 
    outf=open('fractions.updated.txt.'+str(start_index)+'.'+str(end_index),'w') 
    entries=activity_names.items() 
    activity_codes=[i[0] for i in entries] 
    activity_names=[i[1] for i in entries] 
    outf.write('Subject') 
    for activity_name in activity_names: 
        outf.write('\t'+activity_name+'FractionRecorded'+'\t'+activity_name+'Fraction48hrs'+'\t'+activity_name+'LongestGap'+'\t'+activity_name+'Instances')
    outf.write('\n') 
    for subject in full_dict:
        outf.write(subject) 
        for activity in activity_codes: 
            outf.write('\t'+str(full_dict[subject]['fraction'][activity][0])+'\t'+str(full_dict[subject]['fraction'][activity][1])+'\t'+str(full_dict[subject]['gap'][activity][0].total_seconds())+'\t'+str(full_dict[subject]['instance'][activity]))
        outf.write('\n') 
if __name__=="__main__":
    main() 

