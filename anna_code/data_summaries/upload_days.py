from Parameters import * 
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse 

mypath=table_dir
onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]
subject_days=dict() 
ignore=['cardiovascular-appVersion.tsv','derived_age_sex_prediction.tsv']
for f in onlyfiles: 
    if f.endswith('.tsv'): 
        if f in ignore: 
            continue 
        print str(f) 
        data=open(mypath+f,'r').read().split('\n') 
        header=data[0].split('\t') 
        creationdate=header.index('createdOn')
        for line in data[1::]: 
            line=line.split('\t') 
            if len(line)<8: 
                continue 
            subject=line[2] 
            date=line[creationdate].split(' ')[0]  
            if subject not in subject_days: 
                subject_days[subject]=set([]) 
            subject_days[subject].add(date) 




print "making histogram" 
#make a histogram 
days_hist=dict() 
#CONSECUTIVE
'''
for subject in subject_days: 
    cur_up=list(subject_days[subject]) 
    cur_up.sort() 
    previous=parse(cur_up[0]) 
    num_days=1
    for i in range(1,len(cur_up)): 
        current=parse(cur_up[i])
        delta=current-previous
        delta_days=delta.days
        if delta_days<=1: 
            num_days+=1 
            previous=current 
        else: 
            break
    if num_days not in days_hist: 
        days_hist[num_days]=1 
    else: 
        days_hist[num_days]+=1 
print "writing output" 
outf=open('upload_days_consecutive.txt','w') 
for key in days_hist: 
    outf.write(str(key)+'\t'+str(days_hist[key])+'\n') 
'''

#MIN/MAX
for subject in subject_days: 
    cur_up=list(subject_days[subject]) 
    cur_up.sort() 
    first=parse(cur_up[0])
    last=parse(cur_up[-1]) 
    delta=last-first
    num_days=delta.days 
    if num_days not in days_hist: 
        days_hist[num_days]=1 
    else: 
        days_hist[num_days]+=1 
print "writing output" 
outf=open('upload_days_last_minus_first.txt','w') 
for key in days_hist: 
    outf.write(str(key)+'\t'+str(days_hist[key])+'\n') 



