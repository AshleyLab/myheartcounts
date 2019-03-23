import pandas as pd
from os import listdir
from os.path import isfile, join
data=pd.read_csv("/scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitWorkoutCollector-v1.tsv",header=0,sep='\t')
synapse_cache="/scratch/PI/euan/projects/mhc/data/synapseCache"
for index,row in data.iterrows(): 
    blob=str(int(row['data.csv'])) 
    if pd.isnull(blob): 
        continue 
    endblob=blob[-3::].strip('0')
    full_dir='/'.join([synapse_cache,endblob,blob])
    try:
        files=[f for f in listdir(full_dir) if isfile(join(full_dir,f))]
    except:
        continue 
    for f in files:
        if f.endswith('.tmp'): 
            try:
                data=open(full_dir+'/'+f,'r').read().split('\n') 
                for line in data: 
                    print(line) 
            except:
                continue

