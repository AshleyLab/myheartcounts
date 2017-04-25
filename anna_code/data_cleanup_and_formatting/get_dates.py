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
        if t.startswith('car')==False: 
            continue 
        #print str(t) 
        data=open(table_dir+t,'r').read().split('\n')
        if '' in data:
            data.remove('')
        header=data[0]
        if header.split('\t').__contains__('healthCode'):
            for line in data[1::]:
                upload=line.split('\t')[4]
                if upload.startswith('20'): 
                    print str(upload)+'\t'+line.split('\t')[6] 
                

if __name__=="__main__":
    main() 
