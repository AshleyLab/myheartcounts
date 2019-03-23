#NOTE: tested on python 3.6 
import argparse 
import pandas as pd
import numpy as np 
from os import listdir
from os.path import isfile, join

 
def parse_args(): 
    parser=argparse.ArgumentParser(description="Sanitize healthkit entries")
    parser.add_argument("--source_tables",nargs="+",help="healthkit summary tables")
    parser.add_argument("--blob_column_label",type=str,default="data.csv",help="label for blob data within the data table")
    parser.add_argument("--synapse_cache_dir",type=str,default="/scratch/PI/euan/projects/mhc/data/synapseCache",help="directory where data.csv blob files get downloaded") 
    parser.add_argument("--suffix_to_add",type=str,default="sanitized",help="the code will output a sanitized version of the data file, with the suffix appended. Any files that already have the suffix appended will not be further sanitized")
    return parser.parse_args() 

def sanitize_blob_file(path_to_file,suffix_to_add):
    data=pd.read_csv(path_to_file,header=0,sep=',',dtype={"source":str,"sourceIdentifier":str})
    if "source" in data.columns: 
        #clean the "source" values so that we know the device type, but nothing else 
        #for the sourceIdentifier the first 3 sub-parts do not contain user specific info (i.e. com.apple.health, com.withings.wiScaleNG') so we keep just that part. If the parsing fails, just keep the first 3 chars. 
        watch_vals=data.source.str.contains("Watch")==True
        phone_vals=data.source.str.contains("Phone")==True 
        other_vals=((watch_vals==False) & (phone_vals==False)) 
        data.loc[watch_vals,'source']="Watch"
        data.loc[phone_vals,'source']="Phone" 
        data.loc[other_vals,'source']="Other Wearable"         
        data.sourceIdentifier=data.sourceIdentifier.str.split('.')
        for index,row in data.iterrows():
            try:
                data.loc[index,'sourceIdentifier']='.'.join(row['sourceIdentifier'][0:3])
            except:
                continue
        outf='.'.join([path_to_file,suffix_to_add])
        data.to_csv(outf,index=False)
        print(outf)

def get_blob_files(blob,synapse_cache_dir):
    dir1=blob[-3::].lstrip('0')
    if dir1=="":
        dir1="0"
    full_dir='/'.join([synapse_cache_dir,dir1,blob])
    #get all the files in the full directory path for the data blob 
    blob_files=['/'.join([full_dir,f]) for f in listdir(full_dir) if isfile(join(full_dir,f))]
    return blob_files 

def parse_hk_table(table_name,args): 
    table=pd.read_csv(table_name,header=0,sep='\t',dtype={args.blob_column_label:str})
    table=table.dropna(subset=[args.blob_column_label])
    blobs=table[args.blob_column_label]    
    for blob in blobs: 
        blob_files=get_blob_files(blob,args.synapse_cache_dir)
        for blob_file in blob_files: 
            if blob_file.endswith(args.suffix_to_add):
                        continue
            sanitize_blob_file(blob_file,args.suffix_to_add) 

def main(): 
    args = parse_args()
    for table_name in args.source_tables: 
        parse_hk_table(table_name,args) 
    
if __name__=="__main__": 
    main() 

