import sys 
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse 
import datetime 
import numpy 
hr_dir1="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/health_kit/HKQuantityTypeIdentifierHeartRate/" 
hr_dir2="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/cardiovascular_displacement/HKQuantityTypeIdentifierHeartRate/" 
subjects1=[f for f in listdir(hr_dir1) if isfile(join(hr_dir1,f))]
subjects2=[f for f in listdir(hr_dir2) if isfile(join(hr_dir2,f))] 
var_dict=dict() 
start_dict=dict() 
c=0 
startval=int(sys.argv[1])
endval=min(int(sys.argv[2]),len(subjects1))
for s in subjects1[startval:endval]: 
    data=open(hr_dir1+s,'r').read().split('\n') 
    if s not in var_dict: 
        var_dict[s]=[] 
    if s not in start_dict: 
        start_dict[s]=[]
    if '' in data: 
        data.remove('')
    #gottime=False
    lastday=None 
    for line in data: 
        line=line.split('\t')
        indexval=line.index('HKQuantityTypeIdentifierHeartRate')+1
        val=float(line[indexval]) 
        #print str(line[0]) 
        try:
            time=parse(line[0])
        except: 
            continue 
        cur_day=time.day 
        cur_hour=time.hour 
        if cur_day!=lastday: 
            #we are at a new day, check the timestamp!! 
            lastday=cur_day 
            if cur_hour <12: 
                start_dict[s].append(val)             
        var_dict[s].append(val) 
        
#repeat for cardiovascular_displacement subjects 

startval=int(sys.argv[1]) 
endval=min(len(subjects2),int(sys.argv[2]))
if startval < len(subjects2): 
    for s in subjects2[startval:endval]:
        data=open(hr_dir2+s,'r').read().split('\n') 
        if s not in var_dict: 
            var_dict[s]=[] 
        if s not in start_dict: 
            start_dict[s]=[]
        if '' in data: 
            data.remove('')
        gottime=False
        lastday=None 
        for line in data: 
            line=line.split('\t')
            indexval=line.index('HKQuantityTypeIdentifierHeartRate')+1
            val=float(line[indexval])*60 
            try:
                time=parse(line[0])
            except: 
                continue 
            cur_day=time.day 
            cur_hour=time.hour 
            if cur_day!=lastday: 
                #we are at a new day, check the timestamp!! 
                lastday=cur_day 
                if cur_hour <12: 
                    start_dict[s].append(val)             
            var_dict[s].append(val) 

#aggregate! 
outf=open('HR_Variance.txt'+"_"+sys.argv[1]+"_"+sys.argv[2],'w') 
for subject in var_dict: 
    var_val=numpy.var(var_dict[subject]) 
    outf.write(subject+'\t'+str(round(var_val,2))+'\n')
outf=open('HR_First.txt'+"_"+sys.argv[1]+"_"+sys.argv[2],'w') 
for subject in start_dict: 
    if len(start_dict[subject])==0: 
        continue 
    mean_val =sum(start_dict[subject])/len(start_dict[subject])
    outf.write(subject+'\t'+str(round(mean_val,2))+'\n') 


