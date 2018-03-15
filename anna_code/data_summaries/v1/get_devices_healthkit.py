import os 
from os import listdir 
from os.path import isfile,join,isdir

subject_to_devices=dict() 

source_dir1="/home/annashch/myheart/myheart/grouped_timeseries/health_kit/" 
tsvdir=[f for f in listdir(source_dir1) if isdir(join(source_dir1,f))]
for d in tsvdir:
    if d.endswith('/')==False: 
        d=d+'/'
    if d.startswith('.'): 
        continue 
    print str(d) 
    files=[f for f in listdir(source_dir1+d) if isfile(join(source_dir1+d,f))]
    #print str(files) 
    for f in files:
        #print str(f) 
        if f.endswith('.tsv')==False: 
            continue 
        subject=f.replace('.tsv','') 
        if subject not in subject_to_devices: 
            subject_to_devices[subject]=set()  
        data=open(source_dir1+d+f,'r').read().split('\n') 
        while "" in data: 
            data.remove('') 
        if len(data)==0: 
            continue 
        firstline=data[0].split('\t') 
        dev_index=[] 
        for index in range(1,len(firstline)): 
            if firstline[index].startswith('HK'): 
                dev_index.append(index) 
        if len(dev_index)==1: 
            dev_index=dev_index[0]+3 
        else: 
            dev_index=dev_index[1]+5 
        #print "first_line:"+str(firstline) 
        #print "dev_index:"+str(dev_index) 
        for line in data: 
            line=line.split('\t') 
            if len(line)<=dev_index: 
                subject_to_devices[subject].add("unspecified") 
            else: 
                device='\t'.join(line[dev_index::]) 
                subject_to_devices[subject].add(device) 
        
source_dir2="/home/annashch/myheart/myheart/grouped_timeseries/cardiovascular_displacement/" 
tsvdir=[f for f in listdir(source_dir2) if isdir(join(source_dir2,f))]
for d in tsvdir:
    if d.endswith('/')==False: 
        d=d+'/'
    if d.startswith('.'): 
        continue 
    if d=="displacement/": 
        continue 
    print str(d) 
    files=[f for f in listdir(source_dir2+d) if isfile(join(source_dir2+d,f))]
    #print str(files) 
    for f in files:
        #print str(f) 
        if f.endswith('.tsv')==False: 
            continue 
        subject=f.replace('.tsv','') 
        if subject not in subject_to_devices: 
            subject_to_devices[subject]=set()  
        data=open(source_dir2+d+f,'r').read().split('\n') 
        while "" in data: 
            data.remove('') 
        if len(data)==0: 
            continue 
        firstline=data[0].split('\t') 
        dev_index=[] 
        for index in range(1,len(firstline)): 
            if firstline[index].startswith('HK'): 
                dev_index.append(index)  
        if len(dev_index)==1: 
            dev_index=dev_index[0]+3
        else: 
            dev_index=dev_index[1]+5 
        #print "first_line:"+str(firstline) 
        #print "dev_index:"+str(dev_index) 
        for line in data: 
            line=line.split('\t') 
            if len(line)<=dev_index: 
                subject_to_devices[subject].add("unspecified") 
            else: 
                device='\t'.join(line[dev_index::]) 
                subject_to_devices[subject].add(device) 
outf=open('subject_to_device.txt','w') 
for subject in subject_to_devices: 
    outf.write(subject+'\t'+'|'.join(subject_to_devices[subject])+'\n')

