import sys 
from os import listdir
from os.path import isfile, join
mypath=sys.argv[1] 
onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]
for f in onlyfiles: 
    if f.endswith('.filtered'): 
        data=open(mypath+'/'+f,'r').read()
        outf=open(mypath+'/'+f.replace('.filtered',''),'w')
        outf.write(data) 
