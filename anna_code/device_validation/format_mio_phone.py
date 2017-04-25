import sys 
import math 
import datetime

#dirname =sys.argv[1]
subject=sys.argv[1]  
tstart=sys.argv[2]
tstart=datetime.datetime.strptime(tstart,"%Y%m%d%H%M"); 
dirname='/srv/gsfs0/projects/ashley/common/device_validation/subject'+subject 
walk=open(dirname+'/mio_all.tsv','r').read().replace(' ','').split('\n') 
while '' in walk: 
    walk.remove('') 
hr_dict=dict() 
outf=open(dirname+'/mio_'+subject+'.tsv','w')
outf.write('Date\tHeartRate\n')
for line in walk: 
    tokens=line.split(',') 
    time=math.floor(float(tokens[0]))
    hr=float(tokens[1]) 
    if hr < 20: 
        continue 
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

