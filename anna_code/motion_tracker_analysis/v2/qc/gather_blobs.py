import sys 
from os import listdir
from os.path import isfile, join
from shutil import copyfile

blobs=sys.argv[1::]
print(str(blobs))
source_dir='/scratch/PI/euan/projects/mhc/data/synapseCache'
for blob in blobs: 
    outer_dir=blob[-3::].lstrip('0') 
    if outer_dir=="": 
        outer_dir='0'
    mypath=source_dir+'/'+outer_dir+'/'+blob
    print(mypath) 
    onlyfiles = [f for f in listdir(mypath) if isfile(join(mypath, f))]
    for f in onlyfiles: 
        print(f)
        if f.startswith('data'): 
            copyfile(mypath+'/'+f, './'+f)
