#CONCATENATES DATA FRAMES FOR INDIVIDUAL DEVICES 
import sys 
subject=sys.argv[1] 
########################################################################################
dir_name="/srv/gsfs0/projects/ashley/common/device_validation/subject"+str(subject)+"/" 

basis_data=open(dir_name+"basis_"+str(subject)+".tsv",'r').read().split('\n') 
while "" in basis_data: 
    basis_data.remove("") 

fitbit_data=open(dir_name+"fitbit_"+str(subject)+".tsv",'r').read().split('\n') 
while '' in fitbit_data: 
    fitbit_data.remove("") 

microsoft_data=open(dir_name+"microsoft_"+str(subject)+".tsv",'r').read().split('\n') 
while '' in microsoft_data: 
    microsoft_data.remove('') 

apple_data=open(dir_name+"apple_"+str(subject)+".tsv",'r').read().split('\n') 
while '' in apple_data: 
    apple_data.remove("") 

gs_data=open(dir_name+"gold_standard_details_"+str(subject)+'.tsv','r').read().split('\n') 
while '' in gs_data: 
    gs_data.remove('') 

state_data=open(dir_name+"states_"+str(subject)+".tsv",'r').read().split('\n') 
while '' in state_data: 
    state_data.remove('') 
########################################################################################

#COMBINE!!! 

outf=open(dir_name+"combined_"+str(subject)+".tsv",'w') 
times=dict() 

for line in basis_data[1::]: 
    line=line.split('\t')
    start_date=line[0] 
    if ':' in start_date: 
        start_date=line[0].replace(' ','').replace('-','').replace(':','') 
        start_date=start_date+"-0700" 
    else: 
        start_date=line[0] 
    energy=line[1] 
    hr=line[3]
    steps=line[5] 
    if start_date not in times: 
        times[start_date]=dict() 
    times[start_date]['basis']=[hr,energy,steps] 

for line in fitbit_data[1::]: 
    line=line.split('\t') 
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
    times[start_date]['fitbit']=[hr,energy,steps] 

for line in microsoft_data[1::]: 
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
    times[start_date]['microsoft']=[hr,energy,steps] 

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
    times[start_date]['gs']=[hr,energy] 

#write the dictionary to an output file 
outf.write('Date\tBasis_HR\tBasis_Energy\tBasis_Steps\tFitbit_HR\tFitbit_Energy\tFitbit_Steps\tMicrosoft_HR\tMicrosoft_Energy\tMicrosoft_Steps\tApple_HR\tApple_Energy\tApple_Steps\tGoldStandard_HR\tGoldStandard_Energy\n')
for date in times: 
    outf.write(date) 
    for key in ['basis','fitbit','microsoft','apple','gs']: 
        if key in times[date]: 
            entry='\t'.join([i for i in times[date][key]])
            outf.write('\t'+entry) 
        elif key == "gs": 
            outf.write("\tNA\tNA") 
        else: 
            outf.write('\tNA\tNA\tNA') 
    outf.write('\n') 



