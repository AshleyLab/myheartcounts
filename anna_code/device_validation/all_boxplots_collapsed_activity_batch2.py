import numpy
import sys 
#data=open('all','r').read().split('\n')
data=open(sys.argv[1],'r').read().split('\n') 
while '' in data:
    data.remove('')

devices=['mio','samsung','pulseon']
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
    hr_mio=line[3]
    hr_samsung=line[4] 
    hr_pulseon=line[5] 
    gs_hr=line[6]
    
    if  gs_hr=="NA": #ignore any data points where we don't have gs 
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

        if hr_mio=="NA":
            state_to_dropout['mio'][subject][state]+=1
        if steady==True:
            if hr_mio=="NA": 
                state_to_diff['mio'][state].append('NA') 
            else: 
                #diffval=float(hr_mio)-gs_hr
                diffval=(float(hr_mio)-gs_hr)/gs_hr
                state_to_diff['mio'][state].append(diffval)
                if diffval > 5:
                    beats_five['mio'][state]+=1
                if float(gs_hr)==0: 
                    if diffval > 4: 
                        beats_five_percent['mio'][state]+=1 
                elif diffval/float(gs_hr)> 0.05:
                    beats_five_percent['mio'][state]+=1
                
        if (hr_samsung=="NA"):
            state_to_dropout['samsung'][subject][state]+=1
        if (steady==True): 
            if hr_samsung=="NA": 
                state_to_diff['samsung'][state].append('NA') 
            else: 
                #print "hr_samsung:"+str(hr_samsung) 
                #print "gs_hr:"+str(gs_hr) 
                #diffval=float(hr_samsung)-gs_hr
                diffval=(float(hr_samsung)-gs_hr)/gs_hr
                state_to_diff['samsung'][state].append(diffval)
                if diffval >5:
                    beats_five['samsung'][state]+=1
                if float(gs_hr)==0: 
                    if diffval > 4: 
                        beats_five_percent['samsung'][state]+=1 
                elif diffval/float(gs_hr)>0.05:
                    beats_five_percent['samsung'][state]+=1
        
    
        if (hr_pulseon=="NA") :
            state_to_dropout['pulseon'][subject][state]+=1
        elif (steady==True): 
            if hr_pulseon=="NA": 
                state_to_diff['pulseon'][state].append('NA') 
            else: 
                #diffval=float(hr_pulseon)-gs_hr
                diffval=(float(hr_pulseon)-gs_hr)/gs_hr
                state_to_diff['pulseon'][state].append(diffval)
                if diffval > 5:
                    beats_five['pulseon'][state]+=1
                if float(gs_hr)==0: 
                    if diffval  > 4: 
                        beats_five_percent['pulseon'][state]+=1
                elif diffval/float(gs_hr)> 0.05: 
                    beats_five_percent['pulseon'][state]+=1

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
    outf=open('diff_hr_batch2_'+state_of_interest,'w')
    #outf=open('diff_energy_'+state_of_interest,'w')
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



    outf=open('dropped_hr_batch2_'+state_of_interest,'w')
    #outf=open('dropped_energy_'+state_of_interest,'w')
    outf.write('\t'.join(devices)+'\n') 
    numentries=0
    for s in subjects: 
        outf.write(str(s))
        for device in devices: 
            outf.write('\t'+str(percent_dropout[device][state_of_interest][s]))
        outf.write('\n') 
