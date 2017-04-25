#SUMS all the confidence by state files 
import sys 
from helpers import *
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse
from datetime import * 
datadir="/home/annashch/myheartcounts/anna_code/motion_tracker_analysis/"
onlyfiles = [ f for f in listdir(datadir) if isfile(join(datadir,f)) ]
state_dict=dict() 
for f in onlyfiles: 
    if f.startswith('CYCLING_TRANSITIONS.TSV_'): 
        data=open(f,'r').read().split('\n') 
        for line in data[1::]: 
            tokens=line.split('\t') 
            if len(tokens)<2: 
                continue 
            state=tokens[0] 
            countval=float(tokens[1])
            
            if state not in state_dict: 
                state_dict[state]=countval
            else: 
                state_dict[state]+=countval
outf=open('AGGREGATE_CYCLING_TRANSITIONS.TSV','w') 
outf.write('State\tCount\n') 
for state in state_dict: 
    outf.write(state+'\t'+str(state_dict[state])+'\n') 
