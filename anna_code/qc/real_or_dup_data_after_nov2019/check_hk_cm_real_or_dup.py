import pandas as pd 
import datetime 
from os import listdir
from os.path import isfile, join
from dateutil.parser import parse
import pdb 
data_prefix="/oak/stanford/groups/euan/projects/mhc/data/"
file_path="/oak/stanford/groups/euan/projects/mhc/data/tables/cardiovascular-HealthKitDataCollector-v1.tsv"
data= pd.read_csv(file_path,
                  sep='\t',
                  header=0,
                  quotechar='"',
                  index_col=0,
                  dtype={'data.csv':str,
                         'rawData':str,
                         4:str,
                         12:str},
                  parse_dates=['uploadDate','createdOn'],
                  infer_datetime_format=True,
                  error_bad_lines=False,
                  engine='c')

#get files after Nov 1 
print("total entries:"+str(data.shape))
#data['createdOn']=[parse(i) for i in data['createdOn']]
new_data=data[data['createdOn']>datetime.datetime(2019,11,1)]
print("entries after nov 1 , 2019:"+str(new_data.shape))
for index,row in new_data.iterrows(): 
    if row['data.csv'] is not "NA":
        #check timestamp in synapseCache 
        blob=str(row['data.csv'])
        subject=row['healthCode'] 
        blob_prefix=blob[-3::].lstrip('0') 
        blob_folder=data_prefix+"synapseCache/"+blob_prefix+"/"+blob 
        blobfiles = [join(blob_folder,f) for f in listdir(blob_folder) if isfile(join(blob_folder, f))]
        print(blobfiles) 
        for blobfile in blobfiles: 
            cur_blob=pd.read_csv(blobfile,header=0)
            first_date=cur_blob.iloc[0,0] 
            print(first_date) 
            
