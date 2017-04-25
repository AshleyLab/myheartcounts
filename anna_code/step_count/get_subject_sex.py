import statistics 
sex=open('sex','r').read().split('\n') 
while '' in sex: 
    sex.remove('') 
subject_dict=dict() 
for line in sex: 
    tokens=line.split('\t') 
    subject_dict[tokens[0]]=tokens[1] 


steps=open('Health_kit_steps.txt','r').read().split('\n') 
while '' in steps: 
    steps.remove('') 

splits=dict() 
outf=open('Health_kit_steps.augmented.txt','w') 
outf.write('Subject\tMeanStepsPerDay\tSecondsOfAvailableData\tBiologicalSex\n')
for line in steps[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    if subject in subject_dict: 
        subject_sex=subject_dict[subject] 
    else: 
        subject_sex='NA' 
    steps=float(tokens[1])
    duration=float(tokens[2]) 
    outf.write(subject+'\t'+str(int(round(steps)))+'\t'+str(int(round(duration)))+'\t'+subject_sex+'\n') 
    if subject_sex not in splits: 
        splits[subject_sex]=[] 
    if (duration/60.0)> 30: 
        if steps < 200000: 
            splits[subject_sex].append(steps) 
outf=open('averages.txt','w') 
outf.write('BiologicalSex\tMeanStepsPerDay\tStdStepsPerDay\n') 
for sex in splits: 
    #print str(splits[sex]) + sex 
    try:
        meanval=sum(splits[sex])/(1.0*len(splits[sex]))
        std=statistics.stdev(splits[sex])
        outf.write(sex+'\t'+str(meanval)+'\t'+str(std)+'\n') 
    except: 
        continue 
