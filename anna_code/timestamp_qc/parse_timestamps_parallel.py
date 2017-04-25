from Parameters import *
from datetime import datetime
import os 
from os import listdir 
from os.path import isfile,join 
from dateutil.parser import parse
import sys

level1_dir_start=int(sys.argv[1])
level1_dir_end=int(sys.argv[2])
for level1_dir in range(level1_dir_start,level1_dir_end+1):
    level1_dir=str(level1_dir) 
    offsetf=open('offset.txt'+"_"+level1_dir,'w')
    no_offsetf=open('no_offset.txt'+"_"+level1_dir,'w')
    ampm=open('ampm.txt'+"_"+level1_dir,'w')
    weirdness=open('weirdness.txt'+"_"+level1_dir,'w') 
    #level1_dir=[d for d in listdir(synapse_dir)]
    #c=0
    #total=str(len(level1_dir)) 
    #for d1 in level1_dir:
    level2_dir=[d for d in listdir(synapse_dir+level1_dir)]
    #c+=1
    #print str(c)+'/'+total 
    for d2 in level2_dir:
        fullpath=synapse_dir+level1_dir+'/'+d2
        files=[f for f in listdir(fullpath) if isfile(join(fullpath,f))]
        for f in files:
            if f.startswith('.'):
                continue
            if f.startswith('data')==False:
                continue 
            data=open(fullpath+'/'+f,'r').read().replace('\r\n','\n').split('\n')
            while '' in data:
                data.remove('')
            if len(data)<3:
                continue 
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

