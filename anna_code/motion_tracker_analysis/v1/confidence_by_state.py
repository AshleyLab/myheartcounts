import sys 
from helpers import *
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse
from datetime import * 
datadir1="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motiontracker/"
datadir2="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motionactivity/"
outf=open('CONFIDENCE_BY_STATE.TSV'+"_"+sys.argv[1]+"_"+sys.argv[2],'w') 
state_dict=dict() 
onlyfiles = [ f for f in listdir(datadir1) if isfile(join(datadir1,f)) ]
startval=int(sys.argv[1]) 
endval=int(sys.argv[2]) 
if startval > len(onlyfiles): 
    exit() #WE'RE DONE ! 
endval=min([endval,len(onlyfiles)])


c=0 
for f in onlyfiles[startval:endval]: 
    c+=1 
    if c%100==0: 
        print str(c) 
    data=open(datadir1+f,'r').read().split('\n') 
    for line in data: 
        line=line.split('\t') 
        if len(line)<6: 
            continue 
        state=line[1] 
        confidence=line[4] 
        if state not in state_dict: 
            state_dict[state]=dict() 
        if confidence not in state_dict[state]: 
            state_dict[state][confidence]=1 
        else: 
            state_dict[state][confidence]+=1 

startval=int(sys.argv[1]) 
endval=int(sys.argv[2]) 
onlyfiles = [ f for f in listdir(datadir2) if isfile(join(datadir2,f)) ]
if startval < len(onlyfiles): 
    endval=min([endval,len(onlyfiles)])
    c=0 
    for f in onlyfiles[startval:endval]: 
        c+=1 
        if c%100==0: 
            print str(c) 
        data=open(datadir2+f,'r').read().split('\n') 
        for line in data: 
            line=line.split('\t') 
            if len(line)<3: 
                continue 
            state=line[1]
            if state=="not available": 
                state="unknown" 
            confidence=line[2] 
            if state not in state_dict: 
                state_dict[state]=dict() 
            if confidence not in state_dict[state]: 
                state_dict[state][confidence]=1 
            else: 
                state_dict[state][confidence]+=1 
#WRITE THE OUTPUT FILE 
outf.write("State\t0\t1\t2\n") 
for state in state_dict: 
    outf.write(state) 
    for i in ["0","1","2"]: 
        if i not in state_dict[state]: 
            outf.write('\t0') 
        else: 
            outf.write('\t'+str(state_dict[state][i]))
    outf.write('\n') 

