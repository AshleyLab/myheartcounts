from Parameters import *
from datetime import datetime
import os 
from os import listdir 
from os.path import isfile,join 
from dateutil.parser import parse

#categories of timestamp
offsetf=open('offset.txt','w')
no_offsetf=open('no_offset.txt','w')
ampm=open('ampm.txt','w')
weirdness=open('weirdness.txt','w') 

level1_dir=[d for d in listdir(synapse_dir)]
c=0
total=str(len(level1_dir)) 
for d1 in level1_dir:
    level2_dir=[d for d in listdir(synapse_dir+d1)]
    c+=1
    print str(c)+'/'+total 
    for d2 in level2_dir:
        fullpath=synapse_dir+d1+'/'+d2
        files=[f for f in listdir(fullpath) if isfile(join(fullpath,f))]
        for f in files:
            if f.startswith('.'):
                continue
            data=open(fullpath+'/'+f,'r').read().replace('\r\n','\n').split('\n')
            while '' in data:
                data.remove('')
            if len(data)>1:
                #newline delimited file
                firsttime=data[-1].split(',')[0]
                if firsttime.startswith('s'):
                    firsttime=data[-2].split(',')[0]
                elif firsttime.startswith('d'):
                    firsttime=data[-2].split(',')[0]
                if firsttime.count('-')>2 :
                    #offset
                    offsetf.write(fullpath+'/'+f+'\n')
                elif firsttime.count('+')>0:
                    offsetf.write(fullpath+'/'+f+'\n')
                elif firsttime.count('am')>0:
                    ampm.write(fullpath+'/'+f+'\n')
                elif firsttime.count('pm')>0:
                    ampm.write(fullpath+'/'+f+'\n')
                else:
                    try:
                        p=parse(firsttime)
                        no_offsetf.write(fullpath+'/'+f+'\n')
                    except:
                        print fullpath+'/'+f
                        weirdness.write(fullpath+'/'+f+'\n') 
                        
