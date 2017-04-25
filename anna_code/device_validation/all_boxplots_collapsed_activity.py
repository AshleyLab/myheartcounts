import numpy
import sys 
#data=open('all','r').read().split('\n')
data=open(sys.argv[1],'r').read().split('\n') 
while '' in data:
    data.remove('')

devices=['apple','basis','fitbit','microsoft']
states=['sit','walk','run','bike','max']

state_to_diff=dict()
for device in devices:
    state_to_diff[device]=dict()
    for state in states:
        state_to_diff[device][state]=[]
        

state_to_dropout=dict()
for device in devices:
    state_to_dropout[device]=dict()
state_to_totals=dict() 
        
beats_five=dict()
beats_five_percent=dict()
for device in devices:
    beats_five[device]=dict()
    beats_five_percent[device]=dict()
    for state in states:
        beats_five[device][state]=0
        beats_five_percent[device][state]=0
outf_steady=open('steady','w')         
subjects=set([]) 
for i in range(1,len(data)):
    line=data[i]
    line=line.split('\t')
    #print str(line) 
    subject=line[1]
    subjects.add(subject) 

    rawstate=line[2]
    #if rawstate=="transition":
    #    continue 
    if rawstate in ['walk1','walk2']: 
        state="walk" 
    if rawstate in ['run1','run2']: 
        state='run' 
    if rawstate in ['bike1','bike2']: 
        state='bike' 
    if rawstate in ['sit','sit1','sit2','sit3']: 
        state='sit' 
    if rawstate in ['max']: 
        state='max' 
    if subject not in state_to_totals: 
        state_to_totals[subject]=dict() 
    if state not in state_to_totals[subject]: 
        state_to_totals[subject][state]=1 
    else: 
        state_to_totals[subject][state]+=1 
    
    for device in devices: 
        if subject not in state_to_dropout[device]: 
            state_to_dropout[device][subject]=dict() 
        if state not in state_to_dropout[device][subject]: 
            state_to_dropout[device][subject][state]=0 
    #print str(state_to_dropout) 
    hr_basis=line[3]
    energy_basis=line[4]
    hr_basis=energy_basis 
    steps_basis=line[5]

    hr_fitbit=line[6]
    energy_fitbit=line[7]
    hr_fitbit=energy_fitbit 
    steps_fitbit=line[8]

    hr_microsoft=line[9]
    energy_microsoft=line[10]
    hr_microsoft=energy_microsoft
    steps_microsoft=line[11]

    hr_apple=line[12]
    energy_apple=line[13]
    hr_apple=energy_apple 
    steps_apple=line[14]

    
    gs_hr=line[15]
    gs_energy=line[16]
    gs_hr=gs_energy 

    if gs_energy=="NA" and gs_hr=="NA": #ignore any data points where we don't have gs 
        continue 

    steady=False
    if i==(len(data)-1):
        steady=True
    else:
        next_state=data[i+1].split('\t')[2]
        if next_state!=rawstate:
            if state!="transition":
                print "next_state:"+str(next_state)+"; state:"+str(rawstate) 
                steady=True

    if gs_hr!="NA":
        if steady==True: 
            outf_steady.write('\t'.join(line)+'\n')
        print str(line) 
        print str(gs_hr) 
        gs_hr=float(gs_hr) 
        if hr_apple=="NA":
            state_to_dropout['apple'][subject][state]+=1
        if steady==True:
            if hr_apple=="NA": 
                state_to_diff['apple'][state].append('NA') 
            else: 
                diffval=float(hr_apple)-gs_hr
                #diffval=1
                #if gs_hr > 0: 
                #    diffval=(float(hr_apple)-gs_hr)/gs_hr
                state_to_diff['apple'][state].append(diffval)
                if diffval > 5:
                    beats_five['apple'][state]+=1
                if float(gs_hr)==0: 
                    if diffval > 4: 
                        beats_five_percent['apple'][state]+=1
                elif diffval/float(gs_hr)> 0.05:
                    beats_five_percent['apple'][state]+=1
        
        if hr_basis=="NA":
            state_to_dropout['basis'][subject][state]+=1
        if steady==True:
            if hr_basis=="NA": 
                state_to_diff['basis'][state].append('NA') 
            else: 
                diffval=float(hr_basis)-gs_hr
                #diffval=1
                #if gs_hr >0: 
                #    diffval=(float(hr_basis)-gs_hr)/gs_hr
                state_to_diff['basis'][state].append(diffval)
                if diffval > 5:
                    beats_five['basis'][state]+=1
                if float(gs_hr)==0: 
                    if diffval > 4: 
                        beats_five_percent['basis'][state]+=1 
                elif diffval/float(gs_hr)> 0.05:
                    beats_five_percent['basis'][state]+=1
                
        if (hr_fitbit=="NA") and (subject not in ['1']):
            state_to_dropout['fitbit'][subject][state]+=1
        if (subject not in ['1']) and (steady==True): 
            if hr_fitbit=="NA": 
                state_to_diff['fitbit'][state].append('NA') 
            else: 
                #print "hr_fitbit:"+str(hr_fitbit) 
                #print "gs_hr:"+str(gs_hr) 
                diffval=float(hr_fitbit)-gs_hr
                #diffval=1
                #if gs_hr > 0: 
                #    diffval=(float(hr_fitbit)-gs_hr)/gs_hr
                state_to_diff['fitbit'][state].append(diffval)
                if diffval >5:
                    beats_five['fitbit'][state]+=1
                if float(gs_hr)==0: 
                    if diffval > 4: 
                        beats_five_percent['fitbit'][state]+=1 
                elif diffval/float(gs_hr)>0.05:
                    beats_five_percent['fitbit'][state]+=1
        
    
        if (hr_microsoft=="NA") and (subject not in ['1','3']):
            state_to_dropout['microsoft'][subject][state]+=1
        elif (subject not in ['1','3']) and (steady==True): 
            if hr_microsoft=="NA": 
                state_to_diff['microsoft'][state].append('NA') 
            else: 
                diffval=float(hr_microsoft)-gs_hr
                #diffval=1
                #if gs_hr >0: 
                #    diffval=(float(hr_microsoft)-gs_hr)/gs_hr
                state_to_diff['microsoft'][state].append(diffval)
                if diffval > 5:
                    beats_five['microsoft'][state]+=1
                if float(gs_hr)==0: 
                    if diffval  > 4: 
                        beats_five_percent['microsoft'][state]+=1
                elif diffval/float(gs_hr)> 0.05: 
                    beats_five_percent['microsoft'][state]+=1

#GET THE % OF DROPOUT 
percent_dropout=dict() 
#print str(state_to_dropout) 
#print str(state_to_totals) 
for device in devices:
    percent_dropout[device]=dict() 
    for state in states: 
        percent_dropout[device][state]=dict() 
        for subject in list(subjects): 
            try: 
                pd=state_to_dropout[device][subject][state]/float(state_to_totals[subject][state])            
                percent_dropout[device][state][subject]=pd 
            except: 
                percent_dropout[device][state][subject]='NA' 
        
#WRITE THE RESULTS
states_of_interest=['sit','walk','run','bike','max'] 
for state_of_interest in states_of_interest:
    #outf=open('diff_hr_'+state_of_interest,'w')
    outf=open('diff_energy_'+state_of_interest,'w')
    outf.write('\t'.join(devices)+'\n') 
    numentries=0
    for d in devices: 
        if len(state_to_diff[d]['sit']) > numentries: 
            numentries=len(state_to_diff[d][state_of_interest])

    for i in range(numentries): 
        outf.write(str(i))
        for device in devices: 
            try: 
                outf.write('\t'+str(state_to_diff[device][state_of_interest][i]))
            except: 
                outf.write('\tNA')
        outf.write('\n') 



    #outf=open('dropped_hr_'+state_of_interest,'w')
    outf=open('dropped_energy_'+state_of_interest,'w')
    outf.write('\t'.join(devices)+'\n') 
    numentries=0
    for s in subjects: 
        outf.write(str(s))
        for device in devices: 
            outf.write('\t'+str(percent_dropout[device][state_of_interest][s]))
        outf.write('\n') 
