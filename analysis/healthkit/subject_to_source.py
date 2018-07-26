import sys 
from os import listdir
from os.path import isfile, join

datadir="/home/annashch/myheart/myheart/grouped_timeseries/cardiovascular_displacement/HKWorkoutTypeIdentifier/"
onlyfiles = [ f for f in listdir(datadir) if isfile(join(datadir,f)) ]

#startval=int(sys.argv[1]) 
#endval=min(int(sys.argv[2]),len(onlyfiles))
outf=open('device_match_Workout.txt','a')
for i in range(len(onlyfiles)): 
    fname=onlyfiles[i] 
    data=open(datadir+fname,'r').read().split('\n') 
    data.remove('') 
    sources=set([]) 
    for line in data: 
        line=line.split('\t') 
        for j in range(len(line)): 
            if line[j].startswith('HK'):
                #print str(line)+":"+str(j)
                try:
                    sources.add(line[j+3])
                    break 
                except:
                    continue 
    sources='\t'.join([i for i in list(sources)])
    outf.write(fname+'\t'+sources+'\n')

