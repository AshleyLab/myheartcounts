smoking_status=open("smoking_status.tsv",'r').read().strip().split('\n') 
smoking_dict=dict() 
for line in smoking_status: 
    tokens=line.split('\t') 
    smoking_dict[tokens[0]]=[tokens[1],"NA","NA"]

demographics=open("demographics_summary_v1_v2.tsv",'r').read().strip().split('\n') 
for line in demographics[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    if subject in smoking_dict: 
        age=tokens[1] 
        sex=tokens[2] 
        smoking_dict[subject][1]=age 
        smoking_dict[subject][2]=sex 
        
activity=open("/scratch/PI/euan/projects/mhc/data/timeseries_allversions/parsed_HealthKitData.steps.0",'r').read().strip().split('\n') 
activity_dict=dict() 
for line in activity[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    if subject not in smoking_dict: 
        continue 
    device=tokens[-2].lower() 
    if device.__contains__("phone"): 
        date=tokens[1]
        if subject not in activity_dict: 
            activity_dict[subject]=dict() 
        if date in activity_dict[subject]: 
            continue 
        activity_dict[subject][date]=float(tokens[7] )
#average by subject 

outf=open('smoking_vs_hk_steps.tsv','w')
outf.write('Subject\tMeanDailyHkSteps\tSmokingStatus\tAge\tSex\n')
for subject in activity_dict: 
    subject_vals=list(activity_dict[subject].values())
    subject_mean=sum(subject_vals)/len(subject_vals)
    outf.write(subject+'\t'+str(subject_mean)+'\t'+'\t'.join(smoking_dict[subject])+'\n')

