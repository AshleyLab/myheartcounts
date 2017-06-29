def days_in_study_reported_observed(data,outf_name):
    subject_dict=dict()
    for line in data[1::]:
        tokens=line.split('\t')
        subject=tokens[0]
        days_in_study=tokens[1]
        day_index=tokens[3]
        if subject not in subject_dict:
            subject_dict[subject]=dict()
            subject_dict[subject]['days_reported']=days_in_study
            subject_dict[subject]['days_observed']=set([day_index])
        else:
            subject_dict[subject]['days_observed'].add(day_index)
    outf=open(outf_name,'w')
    outf.write('Subject\tDays_In_Study\tDays_With_Data\n')
    for subject in subject_dict:
        outf.write(subject+'\t'+subject_dict[subject]['days_reported']+'\t'+str(len(subject_dict[subject]['days_observed']))+'\n')

def missing_intervention_assignment(data,outf_name):
    subject_dict=dict()
    for line in data[1::]:
        tokens=line.split('\t')
        subject=tokens[0]
        intervention=tokens[2]
        if tokens[2]=="NA":
            subject_dict[subject]=1
    outf=open(outf_name,'w')
    outf.write('\n'.join(subject_dict.keys()))

if __name__=="__main__":
    #TESTS#
    print('TESTS:')
    motion_data=open("/scratch/PI/euan/projects/mhc/data/timeseries_v2/motion_tracker_combined.txt",'r').read().strip().split('\n')
    print("loaded motion data!") 
    health_data=open("/scratch/PI/euan/projects/mhc/data/timeseries_v2/health_kit_combined.txt",'r').read().strip().split('\n')
    print("loaded health data!") 
    days_in_study_reported_observed(motion_data,"/scratch/PI/euan/projects/mhc/data/timeseries_v2/days_in_study_reported_vs_observed.motion")
    print("done:days_in_study_reported_vs_observed motion data") 
    days_in_study_reported_observed(health_data,"/scratch/PI/euan/projects/mhc/data/timeseries_v2/days_in_study_reported_vs_observed.healthkit")
    print("done:days_in_study_reported_vs_observed healthkit data") 
    missing_intervention_assignment(motion_data,"/scratch/PI/euan/projects/mhc/data/timeseries_v2/missing_intervention.motion")
    print("done: missing intervention assignment motion data") 
    missing_intervention_assignment(health_data,"/scratch/PI/euan/projects/mhc/data/timeseries_v2/missing_intervention.healthkit")
    print("done: missing intervention assignment healthkit data") 
