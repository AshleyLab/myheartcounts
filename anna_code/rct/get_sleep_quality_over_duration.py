import pdb
data=open("sleep_healthkit_combined.txt.regression.nodoublecounting",'r').read().strip().split('\n')
outf=open("sleep_healthkit_quality.txt",'w')
outf.write('Subject\tIntervention\tValue\tdayIndex\n')
inbed_dict=dict() 
asleep_dict=dict() 
for line in data[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    dayIndex=tokens[-2] 
    intervention=tokens[4]
    metric=tokens[6] 
    value=float(tokens[7])
    if metric.endswith("InBed"): 
        if subject not in inbed_dict: 
            inbed_dict[subject]=dict() 
        inbed_dict[subject][dayIndex]=[value,intervention]
    else: 
        if subject not in asleep_dict: 
            asleep_dict[subject]=dict() 
        asleep_dict[subject][dayIndex]=[value,intervention] 
print('aggregating') 
for subject in asleep_dict: 
    if subject not in inbed_dict: 
        continue 
    for dayIndex in asleep_dict[subject]: 
        if dayIndex not in inbed_dict[subject]: 
            continue 
        #make sure we are seeing the same intervention for the asleep & inbed metrics 
        try:
            assert asleep_dict[subject][dayIndex][1] == inbed_dict[subject][dayIndex][1] 
        except: 
            print(subject+':'+str(dayIndex))
            continue 
        intervention=asleep_dict[subject][dayIndex][1]
        quality=asleep_dict[subject][dayIndex][0]/inbed_dict[subject][dayIndex][0] 
        outf.write(subject+'\t'+str(intervention)+'\t'+str(quality)+'\t'+dayIndex+'\n')

            

