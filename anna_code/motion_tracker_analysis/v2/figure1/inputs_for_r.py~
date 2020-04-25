data=open('within_subject_measures.txt','r').read().strip().split('\n')
outf_steps=open("HKQuantityTypeIdentifierStepCount.txt",'w')
outf_steps.write('Subject\tIntervention\tDeltaFromBaseline\n')
outf_dist=open("HKQuantityTypeIdentifierDistance.txt",'w')
outf_dist.write('Subject\tIntervention\tDeltaFromBaseline\n')
subject_steps=dict()
subject_steps_baseline=dict() 
subject_dist=dict()
subject_dist_baseline=dict()

outcomes=["HKQuantityTypeIdentifierStepCount","HKQuantityTypeIdentifierDistanceWalk"]
for line in data[1::]:
    tokens=line.split('\t')
    subject=tokens[0]
    outcome=tokens[1]
    if outcome not in outcomes:
        continue    
    intervention=tokens[2]
    value=tokens[3]
    if intervention =="Baseline":
        if outcome.__contains__("Step"):
            subject_steps_baseline[subject]=float(value)
        else:
            subject_dist_baseline[subject]=float(value)
    else:
        if outcome.__contains__("Step"): 
            if subject not in subject_steps:
                subject_steps[subject]=dict()
            subject_steps[subject][intervention]=float(value)
        else:
            if subject not in subject_dist:
                subject_dist[subject]=dict()
            subject_dist[subject][intervention]=float(value)
for subject in subject_steps: 
    try:
        cur_baseline=subject_steps_baseline[subject] 
        for task in subject_steps[subject]: 
            outf_steps.write(subject+'\t'+task+'\t'+str(subject_steps[subject][task]-cur_baseline)+'\n')
    except:
        print("skipping")
        continue
for subject in subject_dist: 
    try:
        cur_baseline=subject_dist_baseline[subject]
        for task in subject_dist[subject]: 
            outf_dist.write(subject+'\t'+task+'\t'+str(subject_dist[subject][task]-cur_baseline)+'\n')
    except:
        print("skipping")
        continue



            
            
