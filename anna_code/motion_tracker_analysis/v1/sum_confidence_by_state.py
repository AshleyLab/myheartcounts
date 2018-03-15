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
    if f.startswith('CONFIDENCE_BY_STATE.TSV_'): 
        data=open(f,'r').read().split('\n') 
        for line in data[1::]: 
            tokens=line.split('\t') 
            if len(tokens)<4: 
                continue 
            state=tokens[0] 
            lowconf=int(tokens[1]) 
            medconf=int(tokens[2]) 
            highconf=int(tokens[3]) 
            if state not in state_dict: 
                state_dict[state]=dict() 
                state_dict[state]['0']=lowconf
                state_dict[state]['1']=medconf 
                state_dict[state]['2']=highconf 
            else: 
                state_dict[state]['0']+=lowconf 
                state_dict[state]['1']+=medconf
                state_dict[state]['2']+=highconf 
outf=open('AGGREGATE_CONFIDENCE.TSV','w') 
outf.write('State\t0\t1\t2\n') 
for state in state_dict: 
    outf.write(state) 
    for conf in ['0','1','2']: 
        outf.write('\t'+str(state_dict[state][conf]))
    outf.write('\n') 
