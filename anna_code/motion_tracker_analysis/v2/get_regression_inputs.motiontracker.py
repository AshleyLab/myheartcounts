#determine day index for use in multivariate linear regression 
# outcome ~ intervention + day-index + device 
import datetime 
import pdb 
import sys 
data=open(sys.argv[1],'r').read().strip().split('\n') 
outf=open(sys.argv[1]+'.regression','w')
#get days when coaching began 
subject_to_start_date=dict() 
start_dates=open("/scratch/PI/euan/projects/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv",'r').read().strip().split('\n') 
for line in start_dates[1::]: 
    tokens=line.split('\t') 
    subject=tokens[5] 
    created_on=datetime.datetime.strptime(tokens[8],'%Y-%m-%d %H:%M:%S').date() 
    if subject not in subject_to_start_date: 
        subject_to_start_date[subject]=[created_on]
    else: 
        subject_to_start_date[subject].append(created_on) 
#pdb.set_trace() 
header=data[0] 
outf.write(header+'\t'+'dayIndex'+'\t'+'WatchVsPhone'+'\n')
valid_interventions=['baseline','cluster','read_aha','stand','walk']
valid_interventions_aws=['APHClusterModule','APHReadAHAWebsiteModule','APHStandModule','APHWalkModule']

for line in data[1::]: 
    tokens=line.split('\t') 
    intervention=tokens[3] 
    #print(intervention)
    if intervention not in valid_interventions: 
        continue 
    subject=tokens[0] 
    day=datetime.datetime.strptime(tokens[1],'%Y-%m-%d').date() 
    #find the day index
    if subject not in subject_to_start_date: 
        continue 
    deltas=[(day-i).days for i in subject_to_start_date[subject]]
    min_delta=deltas[0] 
    for d in deltas: 
        if abs(d) < abs(min_delta): 
            min_delta=d
    day_index=min_delta 
    device_type='phone'
    outf.write(line+'\t'+str(day_index)+'\t'+device_type+'\n')
