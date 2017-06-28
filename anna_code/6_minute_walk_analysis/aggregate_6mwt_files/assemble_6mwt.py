import argparse
import pdb
import os
from shutil import copy
import glob 
from os import listdir
from os.path import isfile, join

def parse_args():
    parser=argparse.ArgumentParser("Aggregate 6 Minute Walk Data")
    parser.add_argument("--source_tables",nargs="+")
    parser.add_argument("--blob_dir") 
    parser.add_argument("--task",choices=["copy_sources","group_by_subject","group_by_metric"],help="copy_sources will copy all 6MWT files to a single directory; group_by_subject will combine all 6MWT files for a single subject into a single file; group_by_activity will combine all 6MWT files for a specified metric into a single file")
    parser.add_argument("--pedometer_walk_dir",default=None)
    parser.add_argument("--accel_walk_dir",default=None)
    parser.add_argument("--device_motion_walk_dir",default=None)
    parser.add_argument("--heart_rate_walk_dir",default=None)
    parser.add_argument("--accel_rest_dir",default=None)
    parser.add_argument("--device_motion_rest_dir",default=None)
    parser.add_argument("--heart_rate_rest_dir",default=None)
    parser.add_argument("--output_dir")
    return parser.parse_args()

def get_metric_indices(metrics,dir_names,output_dir,header):
    indices=[] 
    for i in range(len(metrics)):
        cur_metric=metrics[i]
        cur_dir_name=dir_names[i]
        try:
            index=header.index(cur_metric)+1
            if not  os.path.exists(output_dir+'/'+cur_dir_name):
                os.makedirs(output_dir+'/'+cur_dir_name)        
        except:
            index=None
        indices.append(index)
    return indices


def parse_table(blob_dir,output_dir,source_table,blobs):
    print("parsing:"+str(source_table))
    data=open(source_table,'r').read().strip().split('\n')
    header=data[0].split('\t')
    healthCode_index=header.index('healthCode')+1
    metrics=['pedometer_fitness.walk.items',
             'accel_fitness_walk.json.items',
             'deviceMotion_fitness.walk.items',
             'HKQuantityTypeIdentifierHeartRate_fitness.walk.items',
             'accel_fitness_res.json.items',
             'deviceMotion_fitness.rest.items',
             'HKQuantityTypeIdentifierHeartRate_fitness.rest.items']
    
    dirnames=['pedometer_walk_dir',
              'accel_walk_dir',
              'device_motion_walk_dir',
              'heart_rate_walk_dir',
              'accel_rest_dir',
              'device_motion_rest_dir',
              'heart_rate_rest_dir']    
    indices=get_metric_indices(metrics,dirnames,output_dir,header)
    
    for line in data[1::]:
        tokens=line.split('\t')
        healthCode=tokens[healthCode_index]
        for i in range(len(metrics)):
            if indices[i]!=None:
                blob=tokens[indices[i]]
                if blob!='NA': 
                    if blob not in blobs:
                        blobs[blob]=1
                        full_output_dir=output_dir+"/"+dirnames[i]+"/"+healthCode
                        if not os.path.exists(full_output_dir):
                            os.makedirs(full_output_dir)        
                        #get the last 3 digits of the blob:
                        blob_part1=blob[-3::].lstrip('0')
                        full_source_file=blob_dir+'/'+blob_part1+'/'+blob+'/*.tmp'
                        for f in glob.glob(full_source_file):
                            copy(f,full_output_dir)
    return blobs 
                
def copy_sources(args):
    print("copying sources")
    blobs=dict()
    for source_table in args.source_tables:
        blobs=parse_table(args.blob_dir,args.output_dir,source_table,blobs)
    

#create aggregate json w/ all entries for a subject-- this will be a very large file 
def group_by_subject(args):
    if not os.path.exists(args.output_dir+"/aggregate_by_subject"):
        os.makedirs(args.output_dir+"/aggregate_by_subject")
    #go through metric directory structure & determine which entries are available for each subject 
    subject_dict=dict()
    
    metric_dirs=[args.pedometer_walk_dir,
                 args.accel_walk_dir,
                 args.device_motion_walk_dir,
                 args.heart_rate_walk_dir,
                 args.accel_rest_dir,
                 args.device_motion_rest_dir,
                 args.heart_rate_rest_dir]
    metrics=['pedometer_walk_dir',
             'accel_walk_dir',
             'device_motion_walk_dir',
             'heart_rate_walk_dir',
             'accel_rest_dir',
             'device_motion_rest_dir',
             'heart_rate_rest_dir']    

    pedometer_walk_dir_subjects=[f for f in listdir(args.pedometer_walk_dir)]
    for subject in pedometer_walk_dir_subjects:
        subject_dict[subject]=['pedometer_walk_dir']
    
    

def group_by_metric(args):
    pass 

def perform_task(args):
    return{
        'copy_sources': copy_sources(args),
        'group_by_subject': group_by_subject(args),
        'group_by_metric':group_by_metric(args) 
        }[args.task]

def main():
    #read in the arguments 
    args=parse_args()

    #perform the specified task
    perform_task(args)
    
    
        
if __name__=="__main__":
    main()
        

