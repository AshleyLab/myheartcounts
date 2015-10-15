import sys 
from os import listdir
from os.path import isfile, join
mypath=sys.argv[1] 
onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]
for f in onlyfiles: 
    if f.endswith('.tsv'): 
        data=open(mypath+'/'+f,'r').read().split('\n') 
        header=data[0].split('\t') 
        outf=open(mypath+'/'+f+'.filtered','w') 
        if len(header)==1: 
            header="startDate\tendDate\tvalue\tsource\tunit"
            contents=header+'\n'+'\n'.join(data[1::]) 
        else: 
            contents='\n'.join(data) 
        outf.write(contents) 

