#determine day index for use in multivariate linear regression 
# outcome ~ intervention + day-index + device 
import datetime 
import pdb 
import sys 
data=open(sys.argv[1],'r').read().strip().split('\n') 
outf=open(sys.argv[1]+'.regression','w')

#get days when coaching began 
subject_to_start_date=dict() 
start_dates=open("all.declined",'r').read().strip().split('\n') 
for line in start_dates[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    created_on=datetime.datetime.strptime(tokens[-1],'%Y-%m-%d').date() 
    if subject not in subject_to_start_date: 
        subject_to_start_date[subject]=[created_on]
    else: 
        subject_to_start_date[subject].append(created_on) 
header=data[0] 
outf.write('\t'.join(["Subject","Date","WeekDay","appVersion","ABTest","AWS","Metric","Value","Source","SourceBlobs","dayIndex","WatchVsPhone","dayIndex","WatchVsPhone"])+'\n')
#valid_interventions=['baseline','cluster','read_aha','stand','walk']
#valid_interventions_aws=['APHClusterModule','APHReadAHAWebsiteModule','APHStandModule','APHWalkModule']

for line in data[1::]: 
    tokens=line.split('\t') 
    intervention=tokens[4] 
    #if intervention not in valid_interventions: 
    #    continue 
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
    if day_index < -30: 
        continue 
    if day_index >30: 
        continue 
    if day_index <0: 
        intervention="baseline" 
    else: 
        intervention="declined" 
    tokens[4]=intervention
    tokens[5]=intervention
    if tokens[8].lower().__contains__('phone'): 
        device_type='phone'
    elif tokens[8].lower().__contains__('watch'):
        device_type='watch' 
    else: 
        device_type="unknown"
    outf.write('\t'.join(tokens)+'\t'+str(day_index)+'\t'+device_type+'\n')

        
        
        

