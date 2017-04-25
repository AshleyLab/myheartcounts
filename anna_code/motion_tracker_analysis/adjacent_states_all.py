import sys 
from helpers import *
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse
from datetime import * 
datadir1="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motiontracker/"
datadir2="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motionactivity/"
outf1=open('ALL_TRANSITIONS.TSV'+"_"+sys.argv[1]+"_"+sys.argv[2],'w') 
outf2=open("ALL_TOTALS.TSV"+"_"+sys.argv[1]+"_"+sys.argv[2],'w')

state_dict=dict() 
total_dict=dict() 

onlyfiles = [ f for f in listdir(datadir1) if isfile(join(datadir1,f)) ]
startval=int(sys.argv[1]) 
endval=int(sys.argv[2]) 
if startval > len(onlyfiles): 
    exit() #WE'RE DONE ! 
endval=min([endval,len(onlyfiles)])

c=0 
for f in onlyfiles[startval:endval]: 
    c+=1 
    print str(f) 
    if c%100==0: 
        print str(c) 
    data=open(datadir1+f,'r').read().split('\n') 
    try:
        last_state=data[0].split('\t')[1] 
    except: 
        continue 
    for line in data[1::]: 
        line=line.split('\t') 
        if len(line)<6: 
            continue 
        state=line[1]
        if state not in total_dict: 
            total_dict[state]=1 
        else: 
            total_dict[state]+=1 
        if state!=last_state: 
            transval=tuple([last_state,state])
            if transval not in state_dict: 
                state_dict[transval]=1 
            else: 
                state_dict[transval]+=1 
        last_state=state 
print "part 2:" 
startval=int(sys.argv[1]) 
endval=int(sys.argv[2]) 
onlyfiles = [ f for f in listdir(datadir2) if isfile(join(datadir2,f)) ]
if startval < len(onlyfiles): 
    endval=min([endval,len(onlyfiles)])
    for f in onlyfiles[startval:endval]: 
        data=open(datadir2+f,'r').read().split('\n') 
        try:
            last_state=data[0].split('\t')[1] 
            if last_state=="not available": 
                last_state="unknown" 
        except: 
            continue 
        for line in data[1::]: 
            line=line.split('\t') 
            if len(line)<3: 
                continue 
            state=line[1]
            if state=="not available": 
                state="unknown" 
            if state not in total_dict: 
                total_dict[state]=1 
            else: 
                total_dict[state]+=1 
            if state!=last_state: 
                transval=tuple([last_state,state])
            if transval not in state_dict: 
                state_dict[transval]=1 
            else: 
                state_dict[transval]+=1 
            last_state=state 



#WRITE THE OUTPUT FILE 
for key in state_dict: 
    outf1.write(key[0]+'\t'+key[1]+'\t'+str(state_dict[key])+'\n')
for state in total_dict: 
    outf2.write(state+'\t'+str(total_dict[state])+'\n')
