from parameters import * 
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse 
import datetime 
import numpy 

hr_dir=basedir_cv+hr 
hr_subjects=[f for f in listdir(hr_dir) if isfile(join(hr_dir,f))] 
workout_files=[f for f in listdir(basedir+workout) if isfile(join(basedir+workout,f))]
stair_files=[f for f in listdir(basedir+stairs) if isfile(join(basedir+stairs,f))] 
walkrun_files=[f for f in listdir(basedir+walkrun) if isfile(join(basedir+walkrun,f))] 
cycle_files=[f for f in listdir(basedir+cycle) if isfile(join(basedir+cycle,f))] 
sleep_files=[f for f in listdir(basedir+sleep) if isfile(join(basedir+sleep,f))] 
full_dict=dict() 
keys=set(['stairs','sleep','walk','run','cycle']) 


for subject in hr_subjects:
    print str(subject) 
    hr_dict=dict() #TO LIMIT MEMORY DEMAND, PROCESS 1 SUBJECT AT A TIME 
    workout_vals=dict() 
    stair_vals=[] 
    walk_vals=[] 
    run_vals=[] 
    cycle_vals=[] 
    sleep_vals=[] 
    ##################################################################
    #Build dictionary of heart rate 
    data=open(hr_dir+'/'+subject,'r').read().split('\n') 
    while '' in data: 
        data.remove('') 
    firstline=data[0].split('\t') 
    hr_index=firstline.index("HKQuantityTypeIdentifierHeartRate")+1
    for line in data:
        try:
            tokens=line.split('\t') 
            #print str(tokens) 
            hrval=float(tokens[hr_index]) 
            start_time=parse(tokens[0][0:16]) 
            if tokens[1].startswith('2015'): 
                end_time=parse(tokens[1][0:16])
            else: 
                end_time=start_time 

            #fill in for this time and all in the middle 
            while (start_time <= end_time): 
                hr_dict[start_time]=hrval 
                start_time=start_time+ datetime.timedelta(minutes=1)
        except: 
            continue 
    print "HR DONE"
    if subject in workout_files: 
        #get the workout type data 
        data=open(basedir+workout+'/'+subject,'r').read().split('\n') 
        while '' in data: 
            data.remove('') 
        firstline=data[0].split('\t') 
        workout_type_index=firstline.index("HKWorkoutTypeIdentifier")+1 
        for line in data: 
            try:
                tokens=line.split('\t') 
                start_time=parse(tokens[0][0:16])
                if tokens[1].startswith('2015'): 
                    end_time=parse(tokens[1][0:16]) 
                else: 
                    end_time=start_time 
                workout_type=tokens[workout_type_index] 
                keys.add(workout_type) 
                if workout_type not in workout_vals: 
                    workout_vals[workout_type]=[] 
                while (start_time <=end_time): 
                    if start_time in hr_dict: 
                        workout_vals[workout_type].append(hr_dict[start_time])
                    start_time=start_time+datetime.timedelta(minutes=1) 
            except: 
                continue 
    print "WORKOUT TYPE DONE" 
    if subject in stair_files: 
        #get the stair climb data 
        data=open(basedir+stairs+'/'+subject,'r').read().split('\n') 
        while '' in data: 
            data.remove('') 
        for line in data: 
            try:
                tokens=line.split('\t') 
                start_time=parse(tokens[0][0:16]) 
                if tokens[1].startswith('2015'): 
                    end_time=parse(tokens[1][0:16]) 
                else:
                    end_time=start_time 
                while(start_time <=end_time): 
                    if start_time in hr_dict: 
                        stair_vals.append(hr_dict[start_time]) 
                    start_time=start_time+datetime.timedelta(minutes=1) 
            except: 
                continue 
    print "STAIRS DONE" 
    if subject in walkrun_files: 
        #get the walking/running data
        data=open(basedir+walkrun+'/'+subject,'r').read().split('\n') 
        while '' in data: 
            data.remove('') 
        firstline=data[0].split('\t')  
        val_index=firstline.index("HKQuantityTypeIdentifierDistanceWalkingRunning")+1 
        for line in data: 
            try:
                tokens=line.split('\t') 
                start_time=parse(tokens[0][0:16])
                if tokens[1].startswith('2015'): 
                    end_time=parse(tokens[1][0:16])
                else: 
                    end_time=start_time 
                delta=(parse(tokens[1][0:19])-parse(tokens[0][0:19]))
                if delta.days>0:
                    continue 
                delta=delta.seconds
                while(start_time <=end_time): 
                    if start_time in hr_dict: 
                        #are we walking or running? 
                        #print "val_index:"+str(val_index) 
                        #print "tokens:"+str(tokens) 
                        runwalkval=float(tokens[val_index])
                        speed=runwalkval/delta 
                        if speed < 2.23: 
                            #walking! 
                            if start_time in hr_dict: 
                                walk_vals.append(hr_dict[start_time])
                        else: 
                            #running! 
                            if start_time in hr_dict: 
                                run_vals.append(hr_dict[start_time]) 
                    start_time=start_time+datetime.timedelta(minutes=1) 
            except: 
                continue 
    print "WALK RUN DONE" 
    if subject in cycle: 
        #get the cycling data 
        data=open(basedir+cycle+"/"+subject,'r').read().split('\n') 
        while '' in data: 
            data.remove('') 
        for line in data: 
            try:
                tokens=line.split('\t') 
                start_time=parse(tokens[0][0:16])
                if tokens[1].startswith('2015'): 
                    end_time=parse(tokens[1][0:16]) 
                else: 
                    end_time=start_time 
                while start_time <=end_time: 
                    if start_time in hr_dict: 
                        cycle_vals.append(hr_dict[start_time])
                    start_time=start_time+datetime.delta(minutes=1) 
            except:
                continue 
    print "CYCLE DONE!" 
    if subject in sleep:
        #get the sleep data
        data=open(basedir+sleep+'/'+subject,'r').read().split('\n') 
        while '' in data: 
            data.remove('') 
        for line in data: 
            try:
                tokens=line.split('\t') 
                start_time=parse(tokens[0][0:16])
                if tokens[1].startswith('2015'): 
                    end_time=parse(tokens[1][0:16]) 
                else: 
                    end_time=start_time 
                while start_time <=end_time: 
                    if start_time in hr_dict: 
                        sleep_vals.append(hr_dict[start_time]) 
                    start_time=start_time+datetime.delta(minutes=1) 
            except: 
                continue 
    print "SLEEP DONE!" 
    #summarize the subject results 
    full_dict[subject]=dict() 
    for workout_type in workout_vals: 
        full_dict[subject][workout_type]=numpy.average(workout_vals[workout_type])
    if len(stair_vals)>0: 
        full_dict[subject]['stairs']=numpy.average(stair_vals) 
    if len(walk_vals)>0: 
        full_dict[subject]['walk']=numpy.average(walk_vals) 
    if len(run_vals)>0: 
        full_dict[subject]['run']=numpy.average(run_vals) 
    if len(cycle_vals)>0: 
        full_dict[subject]['cycle']=numpy.average(cycle_vals) 
    if len(sleep_vals)>0: 
        full_dict[subject]['sleep']=numpy.average(sleep_vals) 
#generate output file 
keys=list(keys) 
header='Subject'+'\t'+'\t'.join(keys)
outf=open('HR_for_Activity_State_CV.tsv','w')
outf.write(header+'\n') 
for subject in full_dict: 
    outf.write(subject) 
    for key in keys: 
        if key not in full_dict[subject]: 
            outf.write('\tNA') 
        else: 
            outf.write('\t'+str(full_dict[subject][key])) 
    outf.write('\n') 

 

