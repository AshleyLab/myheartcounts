source="/srv/gsfs0/projects/ashley/common/myheart/grouped_timeseries/6minute_walk/displacement/" 
from os import listdir
from os.path import isfile, join
mypath=source
onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]
subject_to_disp=dict() 
c=0 
for f in onlyfiles: 
    c+=1
    print str(c)
    subject=f.replace('.tsv','') 
    data=open(mypath+f,'r').read().split('\n') 
    data.remove('') 
    if subject not in subject_to_disp: 
        subject_to_disp[subject]=0 
    for line in data[1::]: 
        line=line.split('\t') 
        disp=float(line[3]) 
        subject_to_disp[subject]+=disp 
outf=open('Displacement_6MW.txt','w') 
outf.write('Subject\tMeters') 
for subject in subject_to_disp: 
    outf.write(subject+'\t'+str(subject_to_disp[subject])+'\n') 

    

