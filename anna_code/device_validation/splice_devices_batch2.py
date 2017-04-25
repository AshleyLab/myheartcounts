#CONCATENATES DATA FRAMES FOR INDIVIDUAL DEVICES 
import sys 
subject=sys.argv[1] 
########################################################################################
dir_name="/srv/gsfs0/projects/ashley/common/device_validation/subject"+str(subject)+"/" 

samsung_data=open(dir_name+"samsung_"+str(subject)+".tsv",'r').read().split('\n') 
while "" in samsung_data: 
    samsung_data.remove("") 

mio_data=open(dir_name+"mio_"+str(subject)+".tsv",'r').read().split('\n') 
while '' in mio_data: 
    mio_data.remove("") 

pulseon_data=open(dir_name+"pulseon_"+str(subject)+".tsv",'r').read().split('\n') 
while '' in pulseon_data: 
    pulseon_data.remove('') 

#apple_data=open(dir_name+"apple_"+str(subject)+".tsv",'r').read().split('\n') 
#while '' in apple_data: 
#    apple_data.remove("") 

gs_data=open(dir_name+"DVSTUDY"+str(subject)+'.csv.WITHENERGY','r').read().split('\n') 
while '' in gs_data: 
    gs_data.remove('') 

state_data=open(dir_name+"DVSTUDY"+str(subject)+".csv.STATES",'r').read().split('\n') 
while '' in state_data: 
    state_data.remove('') 
########################################################################################
#make dictionary of states 
state_dict=dict() 
for line in state_data[1::]: 
    tokens=line.split('\t') 
    state=tokens[0] 
    startt=tokens[1] 
    endt=tokens[2] 
    state_dict[startt]=[endt,state] 



#COMBINE!!! 

outf=open(dir_name+"combined_"+str(subject)+".tsv",'w') 
times=dict() 
for line in gs_data[1::]: 
    line=line.split('\t') 
    start_date=line[0]
    if ':' in start_date: 
        start_date=line[0].replace(' ','').replace('-','').replace(':','') 
        start_date=start_date+"-0700" 
    else: 
        start_date=line[0]
    hr=line[1] 
    energy=line[2] 
    if start_date not in times: 
        times[start_date]=dict() 
    times[start_date]['gs']=[hr]#,energy] 


for line in mio_data[1::]: 
    line=line.split('\t')
    start_date=line[0] 
    if ':' in start_date: 
        start_date=line[0].replace(' ','').replace('-','').replace(':','') 
        start_date=start_date+"-0700" 
    else: 
        start_date=line[0] 
    #energy=line[1] 
    hr=line[1]
    #steps=line[5] 
    if start_date not in times: 
        times[start_date]=dict() 
    times[start_date]['mio']=[hr]#,energy,steps] 

for line in samsung_data[1::]: 
    line=line.split('\t') 
    if ':' in start_date: 
        start_date=line[0].replace(' ','').replace('-','').replace(':','') 
        start_date=start_date+"-0700" 
    else: 
        start_date=line[0] 
    hr=line[1] 
    #energy=line[2] 
    #steps=line[3] 
    if start_date not in times: 
        times[start_date]=dict() 
    times[start_date]['samsung']=[hr]#,energy,steps] 

for line in pulseon_data[1::]: 
    line=line.split('\t')
    start_date=line[0] 
    if ':' in start_date: 
        start_date=line[0].replace(' ','').replace('-','').replace(':','') 
        start_date=start_date+"-0700" 
    else: 
        start_date=line[0] 
    hr=line[1] 
    #energy=line[2] 
    #steps=line[3] 
    if start_date not in times: 
        times[start_date]=dict() 
    times[start_date]['pulseon']=[hr]#,energy,steps] 
'''
for line in apple_data[1::]: 
    line=line.split('\t') 
    start_date=line[0]
    if ':' in start_date: 
        start_date=line[0].replace(' ','').replace('-','').replace(':','') 
        start_date=start_date+"-0700" 
    else: 
        start_date=line[0] 
    hr=line[1] 
    energy=line[2] 
    steps=line[3] 
    if start_date not in times: 
        times[start_date]=dict() 
    times[start_date]['apple']=[hr,energy,steps] 
'''


#write the dictionary to an output file 
outf.write('Date\tsubject\tstate\tMio_HR\tSamsung_HR\tPulseon_HR\tGoldStandard_HR\n')
timekeys=times.keys() 
timekeys.sort() 
for date in timekeys: 
    outf.write(date) 
    outf.write('\t'+subject) 
    #determine the current state 
    cur_state="NA" 
    for s in state_dict: 
        if s<=date: 
            upperbound=state_dict[s][0] 
            state_name=state_dict[s][1] 
            if date < upperbound: 
                cur_state=state_name 
                break 
    outf.write('\t'+cur_state) 
    for key in ['mio','samsung','pulseon','gs']: 
        if key in times[date]: 
            entry='\t'.join([i for i in times[date][key]])
            outf.write('\t'+entry) 
        elif key == "gs": 
            outf.write("\tNA") 
        else: 
            outf.write('\tNA') 
    outf.write('\n') 



