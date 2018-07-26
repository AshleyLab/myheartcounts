import sys
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse 

mypath="/home/annashch/myheart/myheart/grouped_timeseries/motiontracker/motiontracker/" 
onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]
subject_days=dict()
subject_hours=dict()  
c=0 
startindex=int(sys.argv[1]) 
endindex=int(sys.argv[2]) 
for f in onlyfiles[startindex:endindex]: 
    c+=1 
    print str(c) 
    if c%100==0: 
        print str(c) 
    if f.endswith('.tsv'): 
        subject_days[f]=set([]) 
        subject_hours[f]=dict() 
        data=open(mypath+f,'r').read().split('\n') 
        for line in data: 
            line=line.split('\t') 
            dt=parse(line[0])
            date=dt.date() 
            subject_days[f].add(date) 
            if date not in subject_hours[f]: 
                subject_hours[f][date]=set([]) 
            subject_hours[f][date].add(dt.hour) 

outf=open('days_'+sys.argv[1]+'_'+sys.argv[2],'w') 
for subject in subject_days: 
    outf.write(str(len(subject_days[subject]))+'\n')
outf=open('hours_'+sys.argv[2]+'_'+sys.argv[2],'w') 
for subject in subject_hours: 
    for day in subject_hours[subject]: 
        outf.write(str(len(subject_hours[subject][day]))+'\n')
