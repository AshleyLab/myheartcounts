source="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/6minute_walk/pedometer/" 
from os import listdir
from os.path import isfile, join
mypath=source
onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]
subject_to_steps=dict() 
c=0 
for f in onlyfiles: 
    c+=1
    print str(c)
    subject=f.replace('.tsv','') 
    data=open(mypath+f,'r').read().split('\n') 
    data.remove('') 
    final=data[-1].split('\t')[2] 
    try: 
        final=int(final) 
    except: 
        continue 
    subject_to_steps[subject]=final 
outf=open('Steps_6MW.txt','w') 
outf.write('Subject\tSteps') 
for subject in subject_to_steps: 
    outf.write(subject+'\t'+str(subject_to_steps[subject])+'\n') 

    
