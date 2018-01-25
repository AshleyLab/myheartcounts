#coaching data levels for 23andme users
prefix="/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/" 
mt_data=open(prefix+"motion_tracker_combined.filtered.txt",'r').read().strip().split('\n')
hk_steps=open(prefix+"healthkit_combined.stepcount.txt",'r').read().strip().split('\n')
hk_distance=open(prefix+"healthkit_combined.distance.txt",'r').read().strip().split('\n')
datasets=dict()
datasets['mt']=mt_data
datasets['hk_steps']=hk_steps
datasets['hk_distance']=hk_distance
subjects_23me=open(prefix+"23andmesubjects.txt",'r').read().strip().split('\n')
subject_dict=dict()

for line in subjects_23me:
    subject_dict[line]=1
for dataset_name in datasets:
    dataset=datasets[dataset_name]
    all_interventions=set([]) 
    interventions=dict()
    for line in dataset: 
        tokens=line.split('\t')
        subject=tokens[0]
        if subject not in subject_dict:
            continue
        intervention=tokens[2]
        all_interventions.add(intervention)
        day=tokens[3]
        if subject not in interventions:
            interventions[subject]=dict()
        if intervention not in interventions[subject]:
            interventions[subject][intervention]=set(day)
        else:
            interventions[subject][intervention].add(day)
    outf=open(dataset_name+'_23andme_intervention_tally.txt','w')
    outf.write('Intervention\t0\t1\t2\t3\t4\t5\t6\t7+\n')
    all_interventions=list(all_interventions)
    summary=dict()
    for intervention in all_interventions:
        summary[intervention]=dict()
        for i in range(0,8):
            summary[intervention][i]=0

        for subject in interventions:
            if intervention not in interventions[subject]:
                num_days=0
            else:
                num_days=min([7,len(interventions[subject][intervention])])
            for j in range(num_days+1):
                summary[intervention][j]+=1
        outf.write(intervention)
        for l in range(0,8):
            outf.write('\t'+str(summary[intervention][l]))
        outf.write('\n')
    
