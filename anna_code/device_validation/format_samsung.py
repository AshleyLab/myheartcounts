import sys 
import math 
import datetime

#dirname =sys.argv[1]
subject=sys.argv[1]  
tstart=sys.argv[2]
tstart=datetime.datetime.strptime(tstart,"%Y%m%d%H%M"); 
dirname='/srv/gsfs0/projects/ashley/common/device_validation/subject'+subject 
walk=open(dirname+'/samsung_walk_'+subject+'.tsv','r').read().replace(' ','').split('\n') 
while '' in walk: 
    walk.remove('') 
run=open(dirname+'/samsung_run_'+subject+'.tsv','r').read().replace(' ','').split('\n') 
while '' in run: 
    run.remove('') 
bike=open(dirname+'/samsung_bike_'+subject+'.tsv','r').read().replace(' ','').split('\n') 
while '' in bike: 
    bike.remove(''); 
vo2max=open(dirname+'/samsung_max_'+subject+'.tsv','r').read().replace(' ','').split('\n') 
while '' in vo2max: 
    vo2max.remove(''); 

outf=open(dirname+'/samsung_'+subject+'.tsv','w')
outf.write('Date\tHeartRate\n')
maxwalk=0 
maxrun=0 
maxbike=0 
hr_dict=dict() 
for line in walk: 
    tokens=line.split(',') 
    time=math.floor(float(tokens[0]))
    hr=float(tokens[1]) 
    if hr < 20: 
        continue 
    if time > maxwalk: 
        maxwalk=time 
    if time not in hr_dict: 
        hr_dict[time]=[hr]
    else: 
        hr_dict[time].append(hr) 
    
for line in run: 
    tokens=line.split(',') 
    time=math.floor(float(tokens[0]))
    hr=float(tokens[1]) 
    if hr < 20: 
        continue 
    time=time+maxwalk; 
    if time > maxrun: 
        maxrun=time 
    if time not in hr_dict: 
        hr_dict[time]=[hr] 
    else: 
        hr_dict[time].append(hr) 

for line in bike: 
    tokens=line.split(',') 
    time=math.floor(float(tokens[0]))
    hr=float(tokens[1]) 
    if hr < 20: 
        continue 
    time=time+maxrun 
    if time > maxbike: 
        maxbike=time
    if time not in hr_dict: 
        hr_dict[time]=[hr] 
    else: 
        hr_dict[time].append(hr) 

for line in vo2max: 
    tokens=line.split(',') 
    time=math.floor(float(tokens[0]))
    hr=float(tokens[1]) 
    if hr < 20: 
        continue 
    time=time+maxbike 
    if time not in hr_dict: 
        hr_dict[time]=[hr] 
    else: 
        hr_dict[time].append(hr) 

        
timevals=hr_dict.keys() 
timevals.sort() 
for val in timevals: 
    meanhr=sum(hr_dict[val])/len(hr_dict[val])
    ts=tstart+datetime.timedelta(minutes=val) 
    tstring=datetime.datetime.strftime(ts,"%Y%m%d%H%M")
    outf.write(tstring+'00-0700'+'\t'+str(meanhr)+'\n')

