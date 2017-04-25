import numpy

data=open('all','r').read().split('\n')
while '' in data:
    data.remove('')

devices=['apple','basis','fitbit','microsoft']
states=['sit','walk1','walk2','run1','run2','bike1','bike2','max']

state_to_diff=dict()
for device in devices:
    state_to_diff[device]=dict()
    for state in states:
        state_to_diff[device][state]=[]
        

state_to_dropout=dict()
for device in devices:
    state_to_dropout[device]=dict()
    for state in states:
        state_to_dropout[device][state]=0
        
beats_five=dict()
beats_five_percent=dict()
for device in devices:
    beats_five[device]=dict()
    beats_five_percent[device]=dict()
    for state in states:
        beats_five[device][state]=0
        beats_five_percent[device][state]=0
        

for i in range(1,len(data)):
    line=data[i]
    line=line.split('\t')
    print str(line) 
    #subject=int(line[1])
    subject=line[1] 

    state=line[2]
    if state=="transition":
        continue 
    hr_basis=line[3]
    energy_basis=line[4]
    steps_basis=line[5]

    hr_fitbit=line[6]
    energy_fitbit=line[7]
    steps_fitbit=line[8]

    hr_microsoft=line[9]
    energy_microsoft=line[10]
    steps_microsoft=line[11]

    hr_apple=line[12]
    energy_apple=line[13]
    steps_apple=line[14]

    
    gs_hr=line[15]
    gs_energy=line[16]

    if gs_energy=="NA" and gs_hr=="NA":
        continue 

    steady=False
    if i==(len(data)-1):
        steady=True
    else:
        next_state=data[i+1].split('\t')[2]
        if next_state!=state:
            if state!="transition":
                steady=True
    
    if gs_hr!="NA":
        gs_hr=float(gs_hr) 
        if (hr_apple=="NA") and (subject not in ["1_2","3_2"]):
            state_to_dropout['apple'][state]+=1
        elif (subject not in ["1_2","3_2"]):
            if steady==True:
                diffval=abs(float(hr_apple)-gs_hr)
                state_to_diff['apple'][state].append(diffval)
                if diffval > 5:
                    beats_five['apple'][state]+=1
                if diffval/float(gs_hr)> 0.05:
                    beats_five_percent['apple'][state]+=1
        
        if (hr_basis=="NA") and (subject not in ["1_2","3_2"]):
            state_to_dropout['basis'][state]+=1
        elif (subject not in ["1_2","3_2"]):
            if steady==True:
                diffval=abs(float(hr_basis)-gs_hr)
                state_to_diff['basis'][state].append(diffval)
                if diffval > 5:
                    beats_five['basis'][state]+=1
                if diffval/float(gs_hr)> 0.05:
                    beats_five_percent['basis'][state]+=1
                
        if (hr_fitbit=="NA") and (subject not in ["1","3_2"]):
            state_to_dropout['fitbit'][state]+=1
        elif (subject not in ["1","3_2"]): 
            if steady==True:
                diffval=abs(float(hr_fitbit)-gs_hr)
                state_to_diff['fitbit'][state].append(diffval)
                if diffval >5:
                    beats_five['fitbit'][state]+=1
                if diffval/float(gs_hr)>0.05:
                    beats_five_percent['fitbit'][state]+=1
        
    
        if (hr_microsoft=="NA") and (subject not in ["1","3"]):
            state_to_dropout['microsoft'][state]+=1
        elif (subject not in ["1","3"]): 
            if steady==True:
                diffval=abs(float(hr_microsoft)-gs_hr)
                state_to_diff['microsoft'][state].append(diffval)
                if diffval > 5:
                    beats_five['microsoft'][state]+=1
                if diffval/float(gs_hr)> 0.05: 
                    beats_five_percent['microsoft'][state]+=1


#WRITE THE RESULTS
outf=open('diff_hr','w')
for device in devices:
    for state in states:
        outf.write(device+"_"+state+'\t')
outf.write('\n')
outf.write('MeanDifference') 
for device in devices:
    for state in states:
        diffvals=state_to_diff[device][state]
        mean_diff=1.0*sum(diffvals)/len(diffvals)
        outf.write('\t'+str(round(mean_diff,3)))
outf.write('\n')
outf.write('StdDevDifference') 
for device in devices:
    for state in states:
        diffvals=state_to_diff[device][state]
        std_dev_diff=numpy.std(diffvals)
        outf.write('\t'+str(round(std_dev_diff,3)))
outf.write('\n')
outf.write('MinutesDropout')
for device in devices:
    for state in states:
        outf.write('\t'+str(state_to_dropout[device][state]))
outf.write('\n')
outf.write('MinutesSteadyStateDiff5Beats')
for device in devices:
    for state in states:
        outf.write('\t'+str(beats_five[device][state]))
outf.write('\n')
outf.write('MinutesSteadyStateDiff5Percent') 
for device in devices:
    for state in states:
        outf.write('\t'+str(beats_five_percent[device][state]))
outf.write('\n')
