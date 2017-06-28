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
    

#create aggregate json w/ all entries for a subject
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

    for i in range(len(metric_dirs)):
        cur_metric_dir=metric_dirs[i]
        cur_metric=metrics[i]
        print("getting subjects for metric:"+str(cur_metric) )
        subject_set=[f for f in listdir(cur_metric_dir)]
        for subject in subject_set:
            if subject not in subject_dict:
                subject_dict[subject]=[tuple([cur_metric,cur_metric_dir])]
            else:
                subject_dict[subject].append(tuple([cur_metric,cur_metric_dir]))
    #generate a json for each subject including all the metrics available for that subject
    #if there are multiple entries for a given metric for a given subject, store them in a list
    num_subjects=str(len(subject_dict.keys()))
    subject_index=0 
    for subject in subject_dict:
        subject_index+=1
        if subject_index%100==0:
            print(subject_index+"/"+num_subjects)
        subject_dict=dict() 
        for metric_tuple in subject_dict[subject]:
            #load the json files
            cur_metric=metric_tuple[0]
            cur_metric_dir=metric_tuple[1]
            subject_dict[cur_metric]=[]
            subject_metric_files=[f for f in in listdir(cur_metric_dir+'/'+subject)]
            for f in subject_metric_files:
                cur_file=open(cur_metric_dir+'/'+subject+f,'r')
                subject_dict[cur_metric].append(json.load(cur_file))
        #all metrics for subject have been processed. Save the subject to aggregate directory.
        outf=open(args.output_dir+"/aggregate_by_subject/"+subject+".json",'w')
        json.dump(subject_dict,outf)
        
    
#create aggregate json w/ all subjects' entries for a single metric - this will be a large file!
def group_by_metric(args):
    if not os.path.exists(args.output_dir+"/aggregate_by_metric"):
        os.makedirs(args.output_dir+"/aggregate_by_metric")
        
    #create jsons for each metric
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
    for i in range(len(metric_dirs)):
        cur_metric_dir=metric_dirs[i]
        cur_metric=metrics[i]
        print("processing metric:"+str(cur_metric))
        metric_dict=dict()
        cur_metric_subjects=[f for f in listdir(cur_metric_dir)]
        for subject in cur_metric_subjects:
            metric_dict[subject]=[]
            subject_metric_files=[f for f in listdir(cur_metric_dir+'/'+subject)]
            for subject_metric_file in subject_metric_files:
                cur_file =open(cur_metric_dir+'/'+subject+'/'+subject_metri_file,'r')
                metric_dict[subject].append(json.load(cur_file))


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
        

