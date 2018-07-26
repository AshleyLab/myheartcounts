import argparse
import pdb
import os
from shutil import copy
import glob 
from os import listdir
from os.path import isfile, join
import json

def parse_args():
    parser=argparse.ArgumentParser("Aggregate Motion Tracker Data")
    parser.add_argument("--source_tables",nargs="+")
    parser.add_argument("--healthCode_indices",type=int,nargs="+")
    parser.add_argument("--resume_from",type=int,default=None)
    parser.add_argument("--blob_dir") 
    parser.add_argument("--output_dir")
    parser.add_argument("--subjects") 
    return parser.parse_args()


def parse_table(blob_dir,output_dir,source_table,healthCode_index,resume_from,subject_dict):
    print("parsing:"+str(source_table))
    data=open(source_table,'r').read().strip().split('\n')
    header=data[0].split('\t')
    lc=0
    start_index=1
    if resume_from!=None:
        start_index=resume_from
        lc=resume_from
    for line in data[start_index::]:
        lc+=1
        if lc%100==0:
            print(str(lc))
        tokens=line.split('\t')
        healthCode=tokens[healthCode_index]
        if healthCode not in subject_dict:
            continue 
        if healthCode=="NA":
            pdb.set_trace()
        blob=tokens[-1]
        if blob!='NA': 
            full_output_dir=output_dir+"/"+healthCode
            if (not os.path.exists(full_output_dir)):
                os.makedirs(full_output_dir)        
            #get the last 3 digits of the blob:
            blob_part1=blob[-3::].lstrip('0')
            full_source_file=blob_dir+'/'+blob_part1+'/'+blob+'/data*'
            for f in glob.glob(full_source_file):
                if not os.path.exists(full_output_dir+'/'+f): 
                    copy(f,full_output_dir)
                    
def copy_sources(args):
    print("copying sources")
    for source_index in range(len(args.source_tables)):
        source_table=args.source_tables[source_index]
        healthCode_index=args.healthCode_indices[source_index]
        subjects=open(args.subjects,'r').read().strip().split('\n')
        subject_dict=dict()
        for subject in subjects:
            subject_dict[subject]=1 
        parse_table(args.blob_dir,args.output_dir,source_table,healthCode_index,args.resume_from,subject_dict)

def main():
    #read in the arguments 
    args=parse_args()

    #perform the specified task
    copy_sources(args)
    
    
        
if __name__=="__main__":
    main()
        

