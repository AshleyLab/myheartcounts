#SUMS all the confidence by state files 
import sys 
from helpers import *
from os import listdir
from os.path import isfile, join
datadir="/home/annashch/myheartcounts/anna_code/motion_tracker_analysis/"
onlyfiles = [ f for f in listdir(datadir) if isfile(join(datadir,f)) ]
state_dict=dict() 
total_dict=dict() 
alltotal=0 

for f in onlyfiles: 
    if f.startswith('ALL_TRANSITIONS.TSV_'): 
        data=open(f,'r').read().split('\n') 
        for line in data: 
            tokens=line.split('\t') 
            if len(tokens)<3: 
                continue 
            state1=tokens[0] 
            state2=tokens[1]
            countval=float(tokens[2])
            if state1 not in state_dict: 
                state_dict[state1]=dict() 
            if state2 not in state_dict[state1]: 
                state_dict[state1][state2]=countval 
            else: 
                state_dict[state1][state2]+=countval 
    elif f.startswith('ALL_TOTALS.TSV_'): 
        data=open(f,'r').read().split('\n') 
        for line in data:
            tokens=line.split('\t') 
            if len(tokens)<2: 
                continue 
            state=tokens[0] 
            countval=int(tokens[1]) 
            if state not in total_dict: 
                total_dict[state]=countval 
            else: 
                total_dict[state]+=countval 
            alltotal+=countval 

#GET EXPECTED AND OBSERVED PROBABILITIES 
probs_expected=dict() 
probs_observed=dict() 
for state in total_dict: 
    probs_expected[state]=total_dict[state]/float(alltotal) 

for state in state_dict: 
    probs_observed[state]=dict() 
    for state2 in state_dict[state]: 
        probval=state_dict[state][state2]/sum(list(state_dict[state].values()))
        probs_observed[state][state2]=probval 

#WRITE THE OUTPUTFILE!! 
outf=open('observed_expected_delta.txt','w') 
states=state_dict.keys() 
outf.write('\t'+'\t'.join(states)) 
for state in states: 
    outf.write(state) 
    for state2 in states: 
        if state2 not in probs_observed[state]: 
            outf.write('\t')
        else: 
            outf.write('\t'+str(round(probs_observed[state][state2],2)))
    outf.write('\n') 
outf.write('\n') 
for state in states: 
    outf.write(state) 
    for state2 in states: 
        if state2 not in probs_observed[state]: 
            outf.write('\t') 
        else: 
            diff=float(probs_observed[state][state2])-probs_expected[state2]
            outf.write('\t'+str(round(diff,2)))
    outf.write('\n') 
