#generate paired t-test input for within subject comparison for HK & MotionTracker 
import numpy as np 
hk_steps=open("/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/health_kit_combined.steps.txt",'r').read().strip().split('\n') 
hk_distance=open('/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/health_kit_combined.distance.txt','r').read().strip().split('\n') 
mt=open("/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/motion_tracker_combined.txt",'r').read().strip().split('\n') 
print('read in data') 
#define thresholds 
max_steps=20000 
max_dist=25000
max_minutes=1440 


#generate dictionary of subject -> intervention -> values 
subject_dict=dict() 
for line in hk_steps[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    source=tokens[-2] 
    if not source.lower().__contains__('phone'):
        continue 
    intervention=tokens[3] 
    measure=tokens[6] 
    value=float(tokens[7]) 
    if intervention=="NA": 
        continue 
    if value >  max_steps: 
        continue 
    if subject not in subject_dict: 
        subject_dict[subject]=dict() 
    if measure not in subject_dict[subject]: 
        subject_dict[subject][measure]=dict() 
    if intervention not in subject_dict[subject][measure]: 
        subject_dict[subject][measure][intervention]=[value] 
    else: 
        subject_dict[subject][measure][intervention].append(value) 
print("processed steps") 


for line in hk_distance[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    source=tokens[-2]
    if not source.lower().__contains__('phone'):
        continue 
    intervention=tokens[4] 
    measure=tokens[6] 
    value=float(tokens[7]) 
    if intervention=="NA": 
        continue 
    if value >  max_dist: 
        continue 
    if subject not in subject_dict: 
        subject_dict[subject]=dict() 
    if measure not in subject_dict[subject]: 
        subject_dict[subject][measure]=dict() 
    if intervention not in subject_dict[subject][measure]: 
        subject_dict[subject][measure][intervention]=[value] 
    else: 
        subject_dict[subject][measure][intervention].append(value) 
print("processed distance")

for line in mt[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    intervention=tokens[4] 
    measure=tokens[5] 
    minutes=float(tokens[6]) 
    fraction=float(tokens[7]) 
    if intervention=="NA": 
        continue 
    if minutes > max_minutes: 
        continue 
    if subject not in subject_dict: 
        subject_dict[subject]=dict() 
    if measure not in subject_dict[subject]: 
        subject_dict[subject][measure]=dict() 
    if intervention not in subject_dict[subject][measure]: 
        subject_dict[subject][measure][intervention]=[[minutes,fraction]] 
    else: 
        subject_dict[subject][measure][intervention].append([minutes,fraction])
print("processed mt")    

#use average intervention values / subject to generate output data frame 
outf=open('within_subject_measures.phone.txt','w') 
outf.write('Subject\tMeasure\tIntervention\tValue\tComputation\n')
for subject in subject_dict: 
    for measure in subject_dict[subject]: 
        for intervention in subject_dict[subject][measure]: 
            #get the mean value 
            entries=subject_dict[subject][measure][intervention] 
            if measure.__contains__('HKQuantityType'): 
                mean_val=sum(entries)/len(entries) 
                computation="Numeric" 
                outf.write(subject+'\t'+measure+'\t'+intervention+'\t'+str(mean_val)+'\t'+computation+'\n')
            else: 
                minutes=[i[0] for i in entries] 
                fractions=[i[1] for i in entries] 
                mean_minutes=sum(minutes)/len(minutes) 
                mean_fractions=sum(fractions)/len(fractions) 
                outf.write(subject+'\t'+measure+'\t'+intervention+'\t'+str(mean_minutes)+'\t'+"Numeric"+'\n')
                outf.write(subject+'\t'+measure+'\t'+intervention+'\t'+str(mean_fractions)+'\t'+"Fraction"+'\n')

