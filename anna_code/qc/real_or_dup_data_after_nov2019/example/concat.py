import pandas as pd 
import datetime 
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse
import pdb 
data_prefix="/oak/stanford/groups/euan/projects/mhc/data/"
file_path="cardiovascular-HealthKitDataCollector-v1.tsv"
outf=open("blobs.concat.tsv",'w') 
data= pd.read_csv(file_path,
                  sep='\t',
                  header=0,
                  quotechar='"',
                  error_bad_lines=False,
                  engine='c',
                  low_memory=False)

#get files after Nov 1 
first=True
for index,row in data.iterrows(): 
    if row['data.csv'] is not "NA":
        #check timestamp in synapseCache 
        blob=str(int(row['data.csv']))
        subject=row['healthCode'] 
        blob_prefix=blob[-3::].lstrip('0')
        if blob_prefix=="": 
            blob_prefix="0"
        blob_folder=data_prefix+"synapseCache/"+blob_prefix+"/"+blob 
        blobfiles = [join(blob_folder,f) for f in listdir(blob_folder) if ((f.startswith('.') is False) and (isfile(join(blob_folder, f))))]
        print(blobfiles) 
        for blobfile in blobfiles: 
            cur_blob=pd.read_csv(blobfile,header=0)
            if first is True: 
                outf.write('Subject\tBlob\t'+'\t'.join([str(i) for i in cur_blob.columns])+'\n')
            for index,row in cur_blob.iterrows(): 
                outf.write(subject+'\t'+blob+'\t'+'\t'.join([str(i) for i in row])+'\n')
outf.close() 
