from helpers import *
from os import listdir
from os.path import isfile, join
import sys 
weekday_dir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/weekday/" 
weekend_dir="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker_sampled/weekend/" 

weekday_subs=dict() 
weekend_subs=dict() 
total_weekday=dict() 
total_weekend=dict() 

weekend_files=[f for f in listdir(weekend_dir) if isfile(join(weekend_dir,f))] 
weekday_files=[f for f in listdir(weekday_dir) if isfile(join(weekday_dir,f))] 

c=0 
for f in weekend_files: 
    c+=1
    if c%100==0: 
        print str(c) 
    data=open(weekend_dir+f,'r').read().split('\n') 
    if '' in data: 
        data.remove('') 
    for line in data: 
        line=line.split('\t') 
        if len(line)<3: 
            continue 
        if line[1]=="unknown": 
            sub=line[2] 
            if sub in weekend_subs: 
                weekend_subs[sub]+=1
            else: 
                weekend_subs[sub]=1 
        else: 
            if line[2] in total_weekend: 
                total_weekend[line[2]]+=1 
            else: 
                total_weekend[line[2]]=1 
        

c=0
for f in weekday_files: 
    c+=1 
    if c%100==0: 
        print str(c) 
    data=open(weekday_dir+f,'r').read().split('\n') 
    if '' in data: 
        data.remove('') 
    for line in data: 
        line=line.split('\t') 
        if len(line) <3: 
            continue 
        if line[1]=="unknown": 
            sub=line[2] 
            if sub in weekday_subs: 
                weekday_subs[sub]+=1
            else: 
                weekday_subs[sub]=1 
        else: 
            if line[2] in total_weekday: 
                total_weekday[line[2]]+=1 
            else: 
                total_weekday[line[2]]=1 
        

outf=open('weekend_subs.txt','w') 
for sub in weekend_subs: 
    outf.write(sub+'\t'+str(weekend_subs[sub])+'\n') 

outf=open('weekday_subs.txt','w') 
for sub in weekday_subs: 
    outf.write(sub+'\t'+str(weekday_subs[sub])+'\n') 

outf=open('weekend_subs_adjusted.txt','w') 
for sub in weekend_subs: 
    if sub in total_weekend: 
        fraction=float(weekend_subs[sub])/float(total_weekend[sub])
        outf.write(sub+'\t'+str(fraction)+'\n') 


outf=open('weekday_subs_adjusted.txt','w') 
for sub in weekday_subs: 
    if sub in total_weekday:
        fraction=float(weekday_subs[sub])/float(total_weekday[sub])
        outf.write(sub+'\t'+str(fraction)+'\n') 

