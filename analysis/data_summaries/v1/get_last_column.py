#gets last column from a directory of files (used to identify all devices used in study) 
from Parameters import * 
from helpers import * 
from datetime import datetime
import os 
from os import listdir 
from os.path import isfile,join 
import sys 
full_dir=sys.argv[1] 
csv_files=[f for f in listdir(full_dir) if isfile(join(full_dir,f))]
values=set() 
total=str(len(csv_files))
counter=0 
for f in csv_files: 
    counter+=1 
    #print str(counter) 
    if counter%1000==0: 
        print str(counter) 
    if f.endswith('.tsv'): 
        data=open(full_dir+'/'+f,'r').read().split('\n') 
        while '' in data: 
            data.remove('') 
        for line in data: 
            lastval=line.split('\t')[-1] 
            if lastval.startswith('com')==False: 
                lastval=line.split('\t')[-2]+'\t'+lastval 
            values.add(lastval) 
for v in values: 
    print str(v) 
