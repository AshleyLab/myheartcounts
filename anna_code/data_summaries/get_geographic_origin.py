#tries to determine the geographic origin of all subjects who have uploaded data since a specified date. 
import sys 
from Parameters import * 
import os 
from os import listdir 
from os.path import isfile,join 


def main(): 
    subject_to_origin=dict() 
    for blobfile in blob_files:
        print str(blobfile) 
        data=open(table_dir+blobfile,'r').read().split('\n')
        if '' in data: 
            data.remove("");
        for line in data[1::]: 
            fields=line.split('\t') 
            subject=fields[2]
            if subject in subject_to_origin: 
                continue 
            blobs=fields[8::] 
            while "NA" in blobs: 
                blobs.remove("NA") 
            if len(blobs)==0: 
                continue 

            blob1=blobs[0]
            upload=fields[5] 
            #get the timestamp 
            last3=blob1[-3:] 
            topdir=last3.lstrip("0")
            if topdir=="": 
                topdir="0" 
            blobdir=synapse_dir+topdir+'/'+blob1+'/' 
            csv_files=[f for f in listdir(blobdir) if isfile(join(blobdir,f))]
            for f in csv_files: 
                if f.endswith('tmp'): 
                    data=open(blobdir+f,'r').read()
                    if data.__contains__("2015")==False: 
                        continue 
                    dateindex=data.index("2015") 
                    dateentry=data[dateindex:dateindex+24] 
                    print str(subject+'\t'+dateentry)
                    subject_to_origin[subject]=1 
if __name__=="__main__": 
    main() 
