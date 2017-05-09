#tally the number of subjects that have undergone each intervention
motion_data=open('/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/subject_intervention_list.motion.txt','r').read().strip().split('\n')
healthkit_step_data=open('/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/subject_intervention_list.healthkit.stepcount.txt','r').read().strip().split('\n')
healthkit_distance_data=open('/scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/subject_intervention_list.healthkit.distance.txt','r').read().strip().split('\n')

motion_subject_dict=dict() #subject --> intervention -->count
healthkit_step_dict=dict()
healthkit_distance_dict=dict()

#build dictionary for motion tracker data 
for line in motion_data:
    tokens=line.split('\t')
    subject=tokens[0]
    intervention=tokens[1]
    if intervention=="Intervention":
        continue #this isn't a real intervention, just a label 
    if subject not in motion_subject_dict:
        motion_subject_dict[subject]=dict()
    if intervention not in motion_subject_dict[subject]:
        motion_subject_dict[subject][intervention]=1
    else:
        motion_subject_dict[subject][intervention]+=1

#build dictionary for healthkit step count data
for line in healthkit_step_data:
    tokens=line.split('\t')
    subject=tokens[0]
    intervention=tokens[1]
    if intervention=="Intervention":
        continue 
    if subject not in healthkit_step_dict:
        healthkit_step_dict[subject]=dict()
    if intervention not in healthkit_step_dict[subject]:
        healthkit_step_dict[subject][intervention]=1
    else:
        healthkit_step_dict[subject][intervention]+=1

#build dictionary for healthkit distance data
for line in healthkit_distance_data[1::]:
    tokens=line.split('\t')
    subject=tokens[0]
    intervention=tokens[1]
    if intervention=="Intervention":
        continue 
    if subject not in healthkit_distance_dict:
        healthkit_distance_dict[subject]=dict()
    if intervention not in healthkit_distance_dict[subject]:
        healthkit_distance_dict[subject][intervention]=1
    else:
        healthkit_distance_dict[subject][intervention]+=1

#tally up the subject count for each intervention, based on a varying min_days_of_data threshold
min_days_of_data=[1,2,3,4,5,6,7] 
outf=open('/scratch/PI/euan/projects/mhc/code/anna_code/data_summaries/v2/tally_interventions.txt','w')
outf.write('Intervention\tMinDaysWithData\tMotionTrackerSubjects\tHealthKitStepSubjects\tHealthKitDistanceSubjects\n')
for day_thresh in min_days_of_data:
    interventions=set([])
    motion_summaries=dict()
    for subject in motion_subject_dict:
        for intervention in motion_subject_dict[subject]:
            interventions.add(intervention) 
            if intervention not in motion_summaries:
                motion_summaries[intervention]=0
            count=motion_subject_dict[subject][intervention]
            if count >=day_thresh:
                motion_summaries[intervention]+=1
    healthkit_step_summaries=dict()
    for subject in healthkit_step_dict:
        for intervention in healthkit_step_dict[subject]:
            interventions.add(intervention)
            if intervention not in healthkit_step_summaries:
                healthkit_step_summaries[intervention]=0
            count=healthkit_step_dict[subject][intervention]
            if count >=day_thresh:
                healthkit_step_summaries[intervention]+=1
    
    healthkit_distance_summaries=dict()
    for subject in healthkit_distance_dict:
        for intervention in healthkit_distance_dict[subject]:
            interventions.add(intervention)
            if intervention not in healthkit_distance_summaries:
                healthkit_distance_summaries[intervention]=0
            count=healthkit_distance_dict[subject][intervention]
            if count >=day_thresh:
                healthkit_distance_summaries[intervention]+=1
    for intervention in interventions:
        outf.write(intervention+\
        '\t'+str(day_thresh)+\
        '\t'+str(motion_summaries[intervention])+\
        '\t'+str(healthkit_step_summaries[intervention])+\
        '\t'+str(healthkit_distance_summaries[intervention])+'\n')
        
    #get the number of subjects that have any intervention
    any_motion=0
    any_healthkit_steps=0
    any_healthkit_distance=0
    for subject in motion_subject_dict:
        for intervention in motion_subject_dict[subject]:
            curval=motion_subject_dict[subject][intervention]
            if curval >=day_thresh:
                any_motion+=1
                break
    for subject in healthkit_step_dict:
        for intervention  in healthkit_step_dict[subject]:
            curval=healthkit_step_dict[subject][intervention]
            if curval >=day_thresh:
                 any_healthkit_steps+=1
                 break
    for subject in healthkit_distance_dict:
        for intervention in healthkit_distance_dict[subject]:
            curval=healthkit_distance_dict[subject][intervention]
            if curval>=day_thresh:
                any_healthkit_distance+=1
    outf.write('Any'+\
               '\t'+str(day_thresh)+\
               '\t'+str(any_motion)+\
               '\t'+str(any_healthkit_steps)+\
               '\t'+str(any_healthkit_distance)+'\n')
    
    
        
