import argparse 
import pandas as pd
from os import listdir 
from os.path import isfile,join 
import numpy as np 
from datetime import datetime,timedelta,date
from dateutil.parser import parse
import pdb 

#do not record sleep entries < 1 hour in duration 
min_time_interval=60*60

def parse_args(): 
    parser=argparse.ArgumentParser(description="get time to bed, time out of bed, time to sleep, time awake") 
    parser.add_argument("--healthKitSleepCollector",default="/scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitSleepCollector-v1.tsv") 
    parser.add_argument("--synapseCache",default="/scratch/PI/euan/projects/mhc/data/synapseCache") 
    parser.add_argument("--subjects_file",default=None) 
    parser.add_argument("--out_prefix",default="out") 
    return parser.parse_args() 

def main(): 
    args=parse_args() 
    data=pd.read_csv(args.healthKitSleepCollector,header=0,sep='\t',index_col=0)
    print("loaded healthKitSleepCollector file") 

    subjects=None 
    if args.subjects_file is not None: 
        subject_dict=dict() 
        subjects=open(args.subject_file,'r').read().strip().split('\n') 
        for line in subjects: 
            subject_dict[subject]=1
    print("got subject subset") 
    
    #set up the metadata for parsing sleep 
    print("set up blob datatype and field name dictionary") 
    out_dict=dict() 
    header=['healthCode','startTime','type','categoryValue','value','unit','source','sourceIdentifier']
    out_dict['HKCategoryValueSleepAnalysisInBed']=open(args.out_prefix+'.HKCategoryValueSleepAnalysisInBed','w')
    out_dict['HKCategoryValueSleepAnalysisInBed'].write('\t'.join(header)+'\n')
    out_dict['HKCategoryValueSleepAnalysisAsleep']=open(args.out_prefix+'.HKCategoryValueSleepAnalysisAsleep','w') 
    out_dict['HKCategoryValueSleepAnalysisAsleep'].write('\t'.join(header)+'\n')
    print("created dictionary of output files") 
    num_parsed=0
    nrows=str(data.shape[0]) 
    for index,row in data.iterrows(): 
        num_parsed+=1
        if num_parsed%1000==0: 
            print(str(num_parsed)+"/"+nrows)

        cur_healthCode=row['healthCode'] 
        if ((subjects!=None) and (cur_healthCode not in subject_dict)): 
            continue 
        try: 
            blob=str(int(row['data.csv']))
        except: 
            continue 
        blob_prefix=blob[-3::].lstrip('0')
        if blob_prefix=="": 
            blob_prefix="0"
        #get all the blob files to load 
        blob_prefix='/'.join([args.synapseCache,blob_prefix,blob])
        blob_files=[f for f in listdir(blob_prefix) if isfile(join(blob_prefix,f))]
        for blob_file in blob_files: 
            file_path=join(blob_prefix,blob_file)
            try:
                data=pd.read_csv(file_path,sep=',',dtype='str',engine='c')
                #print("loaded:"+str(file_path))
            except:
                print("There was a problem importing:"+str(file_path))
                continue 
            #parse the data frame for this blob 
            try: 
                for index,row in data.iterrows(): 
                    datatype=row[2] 
                    val=int(row[3]) 
                    if val<min_time_interval: 
                        continue 
                    out_dict[datatype].write(str(cur_healthCode)+'\t'+'\t'.join([str(i) for i in row])+'\n')
            except:
                print("There was a problem parsing:"+str(file_path))
                
if __name__=="__main__": 
    main() 
