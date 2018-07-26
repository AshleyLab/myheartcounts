import sys 
from helpers import *
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse
from datetime import * 
datadir1="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motiontracker/"
datadir2="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/motiontracker/motionactivity/"
outf=open('CYCLING_TRANSITIONS.TSV'+"_"+sys.argv[1]+"_"+sys.argv[2],'w') 
state_dict=dict() 

onlyfiles = [ f for f in listdir(datadir1) if isfile(join(datadir1,f)) ]
startval=int(sys.argv[1]) 
endval=int(sys.argv[2]) 
if startval > len(onlyfiles): 
    exit() #WE'RE DONE ! 
endval=min([endval,len(onlyfiles)])


for f in onlyfiles[startval:endval]: 
    data=open(datadir1+f,'r').read().split('\n') 
    last_state=data[0].split('\t')[1] 
    for line in data[1::]: 
        line=line.split('\t') 
        if len(line)<6: 
            continue 
        state=line[1]
        if (state!="cycling") and (last_state=="cycling"):
            if state not in state_dict: 
                state_dict[state]=1 
            else: 
                state_dict[state]+=1 
        elif (state=="cycling") and (last_state!="cycling"): 
            if last_state not in state_dict: 
                state_dict[last_state]=1 
            else: 
                state_dict[last_state]+=1 
        last_state=state 

startval=int(sys.argv[1]) 
endval=int(sys.argv[2]) 
onlyfiles = [ f for f in listdir(datadir2) if isfile(join(datadir2,f)) ]
if startval < len(onlyfiles): 
    endval=min([endval,len(onlyfiles)])
    for f in onlyfiles[startval:endval]: 
        data=open(datadir2+f,'r').read().split('\n') 
        last_state=data[0].split('\t')[1] 
        for line in data: 
            line=line.split('\t') 
            if len(line)<3: 
                continue 
            state=line[1]
            if state=="not available": 
                state="unknown" 
            if (state!="cycling") and (last_state=="cycling"):
                if state not in state_dict: 
                    state_dict[state]=1 
                else: 
                    state_dict[state]+=1 
            elif (state=="cycling") and (last_state!="cycling"): 
                if last_state not in state_dict: 
                    state_dict[last_state]=1 
                else: 
                    state_dict[last_state]+=1 
            last_state=state 


#WRITE THE OUTPUT FILE 
outf.write("State\tCount\n") 
for state in state_dict: 
    outf.write(state+'\t'+str(state_dict[state])+'\n') 
