import pandas as pd
import sys 
import os 
prefix="/oak/stanford/groups/euan/projects/mhc/data/tables" 
synapseCache="/oak/stanford/groups/euan/projects/mhc/data/synapseCache"
data=pd.read_csv("/".join([prefix,sys.argv[1]]),header=0,sep='\t')
print("loaded df") 
numrows=str(data.shape[0])
for index,row in data.iterrows(): 
    if index%1000==0: 
        print(str(index)+'/'+numrows)
    if not pd.isna(row['data.csv']): 
        blob=str(int(row['data.csv']))
        blob_suffix=blob[-3::].lstrip('0')
        if blob_suffix=="": 
            blob_suffix="0"
        target_dir="/".join([synapseCache,blob_suffix,blob])
        #print(target_dir)
        if os.path.isdir(target_dir):
            pass
        else: 
            print('\t'.join([str(i) for i in row]))

            
