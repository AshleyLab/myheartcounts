#determine day index for use in multivariate linear regression 
# outcome ~ intervention + day-index + device 
import datetime 
import pdb 
import sys 
data=open(sys.argv[1],'r').read().strip().split('\n') 
outf=open(sys.argv[1]+'.regression','w')
header=data[0] 
outf.write(header+'\t'+'dayIndex'+'\t'+'WatchVsPhone'+'\n')
subject_dict=dict() 
valid_interventions=['baseline','cluster','read_aha','stand','walk']

valid_interventions_aws=['APHClusterModule','APHReadAHAWebsiteModule','APHStandModule','APHWalkModule']
for line in data[1::]: 
    tokens=line.split('\t') 
    #USE ABTEST SCHEDULED INTERVENTION
    intervention=tokens[4] 
    if intervention=="NA": 
        continue 
    subject=tokens[0] 
    day=datetime.datetime.strptime(tokens[1],'%Y-%m-%d').date() 
    #keep track of valid interventions 
    if intervention in valid_interventions: 
        if subject not in subject_dict: 
            subject_dict[subject]=dict() 
            subject_dict[subject]['first']=day
            subject_dict[subject]['last']=day
        elif (day > subject_dict[subject]['last']): 
            subject_dict[subject]['last']=day 
        elif (day < subject_dict[subject]['first']): 
            subject_dict[subject]['first']=day 
print("done w/ first pass") 
for line in data[1::]: 
    tokens=line.split('\t') 
    intervention=tokens[4] 
    if intervention=="NA": 
        continue 
    subject=tokens[0] 
    if subject not in subject_dict: 
        continue 
    day=datetime.datetime.strptime(tokens[1],'%Y-%m-%d').date() 
    print(intervention) 
    day_index=(day-subject_dict[subject]['first']).days 
    if tokens[8].lower().__contains__('phone'): 
        device_type='phone'
    elif tokens[8].lower().__contains__('watch'):
        device_type='watch' 
    else: 
        device_type="unknown"
    outf.write(line+'\t'+str(day_index)+'\t'+device_type+'\n')

        
        
        

