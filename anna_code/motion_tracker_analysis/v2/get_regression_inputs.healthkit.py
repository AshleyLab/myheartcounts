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
valid_interventions=['APHClusterModule','APHReadAHAWebsiteModule','APHStandModule','APHWalkModule']
for line in data[1::]: 
    tokens=line.split('\t') 
    intervention=tokens[2] 
    if intervention=="NA": 
        continue 
    subject=tokens[0] 
    day=datetime.datetime.strptime(tokens[3],'%Y-%m-%d').date() 
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
    intervention=tokens[2] 
    if intervention=="NA": 
        continue 
    subject=tokens[0] 
    if subject not in subject_dict: 
        continue 
    day=datetime.datetime.strptime(tokens[3],'%Y-%m-%d').date() 
    print(intervention) 
    day_index=(day-subject_dict[subject]['first']).days 
    #drop any baseline values more than a week before first intervention-- handles case when subjects have large data gaps 
    if (day_index <-8): 
        continue 
    #we only look at 1 week post final intervention 
    if (day_index > 50): 
        continue 
    if tokens[6].lower().__contains__('phone'): 
        device_type='phone'
    else: 
        device_type='watch' 
    outf.write(line+'\t'+str(day_index)+'\t'+device_type+'\n')

        
        
        

