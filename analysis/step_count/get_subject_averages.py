import statistics 
data=open('Health_kit_steps.txt','r').read().split('\n') 
while '' in data: 
    data.remove('') 

splits=dict() 
for line in data[1::]: 
    tokens=line.split('\t') 
    steps=float(tokens[1])
    subject_sex=tokens[2]
    if subject_sex=="": 
        subject_sex="NA" 
    if subject_sex not in splits: 
        splits[subject_sex]=[] 
    splits[subject_sex].append(steps) 
outf=open('averages.txt','w') 
outf.write('BiologicalSex\tMeanStepsPerDay\tStdStepsPerDay\n') 
for sex in splits: 
    #print str(splits[sex]) + sex 
    try:
        meanval=sum(splits[sex])/(1.0*len(splits[sex]))
        std=statistics.stdev(splits[sex])
        outf.write(sex+'\t'+str(round(meanval))+'\t'+str(round(std))+'\n') 
    except: 
        continue 
