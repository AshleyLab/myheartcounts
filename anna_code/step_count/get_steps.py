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
######################################################

#Determine whether subject has enough datapoints to be included in the analysis 
def includeSubject(filename): 
    #print "checking include..." + str(filename_weekday) 
    data=open(filename,'r').read().split('\n')
    while '' in data: 
        data.remove('') 
    if len(data)<5: 
        return False 
    tokens=data[1].split('\t') 
    if len(tokens)<3: 
        return False 
    if tokens[2]=="HKQuantityTypeIdentifierStepCount": 
        return True 
    return False 

def process_subject(filename): 
    data=split_lines(filename) 
    data.sort() 
    overall_duration=0 
    day_to_vals=dict() 
    for line in data[1::]: 
        try:
            tokens=line.split('\t') 
            end_time=parse(tokens[1],ignoretz=True)
            start_time=parse(tokens[0],ignoretz=True) 
            delta_seconds=(end_time-start_time).total_seconds() 
            overall_duration+=delta_seconds 
            end_day=end_time.replace(hour=0,minute=0,second=0,microsecond=0) 
        except: 
            continue 
        if end_day not in day_to_vals: 
            day_to_vals[end_day]=int(tokens[3])
        else: 
            day_to_vals[end_day]+=int(tokens[3])
    all_steps=day_to_vals.values() 
    mean_steps_per_day=sum(all_steps)/(1.0*len(all_steps))     
    return mean_steps_per_day,overall_duration

def main():
    start_index=int(sys.argv[1]) 
    end_index=int(sys.argv[2]) 
    
    
    datadir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierStepCount/"
    full_dict=dict() # one entry per subject 
    onlyfiles = [ f for f in listdir(datadir) if isfile(join(datadir,f))]
    total_subjects=len(onlyfiles) 
    for f in onlyfiles[start_index:min(end_index,len(onlyfiles))]: 
        print str(f) 
        subject=f.split('.')[0]
        include=includeSubject(datadir+f)
        if include==False: 
            continue 
        steps,duration=process_subject(datadir+f)
        full_dict[subject]=[steps,duration] 

    #generate output file 
    outf=open('Health_kit_steps.txt.'+str(start_index)+'.'+str(end_index),'w') 
    outf.write('Subject\tMeanStepsPerDay\tHealthKitDataRecorded(Seconds)\n') 
    for subject in full_dict: 
        outf.write(subject+'\t'+str(full_dict[subject][0])+'\t'+str(full_dict[subject][1])+'\n') 

if __name__=="__main__":
    main() 

