#GETS A LIST OF ALL THE HEALTH CODE ID'S IN THE STUDY
from Parameters import *
import os 
from os import listdir 
from os.path import isfile,join,exists

def main():
    from Parameters import * 
    if table_dir.endswith('/')==False:
        table_dir=table_dir+"/" 
    table_files=[f for f in listdir(table_dir) if isfile(join(table_dir,f))]
    
    subjects=set()
    for t in table_files:
        if t.__contains__("meta"):
            continue # ignore metadata files
        print str(t) 
        data=open(table_dir+t,'r').read().split('\n')
        if '' in data:
            data.remove('')
        header=data[0]
        if header.split('\t').__contains__('healthCode'):
            for line in data[1::]:
                subject=line.split('\t')[2]
                if len(subject)!=len('61ae4d69-c442-44d6-baad-a5cf9a73fae2'): 
                    continue 
                subjects.add(subject)
    outf=open(subject_file,'w')
    for subject in subjects:
        outf.write(subject+'\n')
    print "There are :"+str(len(subjects))+ " total subject"     

if __name__=="__main__":
    main() 
