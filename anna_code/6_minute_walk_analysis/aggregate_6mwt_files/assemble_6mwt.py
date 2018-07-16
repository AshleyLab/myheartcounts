import argparse
import pdb
import os
from shutil import copyfile
import glob 
from os import listdir
from os.path import isfile, join
import json

def parse_args():
    parser=argparse.ArgumentParser("Aggregate 6 Minute Walk Data")
    parser.add_argument("--source_tables",nargs="+")
    parser.add_argument("--healthCode_indices",type=int,nargs="+")
    parser.add_argument("--resume_from",type=int,default=None)
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
    parser.add_argument("--subject_index",type=int,nargs="*",default=[]) 
    parser.add_argument("--subjects_to_ignore",type=str,default=None)
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


def parse_table(blob_dir,output_dir,source_table,healthCode_index,resume_from):
    print("parsing:"+str(source_table))
    data=open(source_table,'r').read().strip().split('\n')
    header=data[0].split('\t')
    

    metrics=['pedometer_fitness.walk.items',
             'accel_fitness_walk.json.items',
             'deviceMotion_fitness.walk.items',
             'HKQuantityTypeIdentifierHeartRate_fitness.walk.items',
             'accel_fitness_rest.json.items',
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
    print(indices)
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
        if healthCode=="NA":
            pdb.set_trace() 
        for i in range(len(metrics)):
            if indices[i]!=None:
                try:
                    blob=tokens[indices[i]]
                except: 
                    print(line+"\t"+str(indices[i]))
                    continue 
                if blob!='NA': 
                    full_output_dir=output_dir+"/"+dirnames[i]+"/"+healthCode
                    if (not os.path.exists(full_output_dir)):
                        os.makedirs(full_output_dir)        
                    #get the last 3 digits of the blob:
                    blob_part1=blob[-3::].lstrip('0')
                    full_source_file=blob_dir+'/'+blob_part1+'/'+blob+'/*.tmp'
                    cur_blob_index=0 
                    for f in glob.glob(full_source_file):
                        output_file='.'.join([blob,str(cur_blob_index)])
                        full_output_file='/'.join([full_output_dir,output_file])
                        if not os.path.exists(full_output_file): 
                            copyfile(f,full_output_file)                
def copy_sources(args):
    print("copying sources")
    for source_index in range(len(args.source_tables)):
        source_table=args.source_tables[source_index]
        healthCode_index=args.healthCode_indices[source_index] 
        parse_table(args.blob_dir,args.output_dir,source_table,healthCode_index,args.resume_from)
    

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
    print(str(num_subjects))
    if len(args.subject_index)>0:
        subject_keys=args.subject_index
    else:
        subject_keys=range(0,num_subjects)
    subjects=subject_dict.keys()

    if args.subject_to_ignore!=None:
        finished=open(args.subjects_to_ignore,'r').read().strip().split('\n')
        subjects=list(set(subjects) - set(finished))
        num_subjects=len(subjects)
        subject_keys=range(0,num_subjects)
        print(str(len(subjects)))
    for key in subject_keys:
        subject=subjects[key]
        print(str(subject))
        aggregate_dict=dict() 
        for metric_tuple in subject_dict[subject]:
            #pdb.set_trace() 
            #load the json files
            cur_metric=metric_tuple[0]
            cur_metric_dir=metric_tuple[1]
            aggregate_dict[cur_metric]=[]
            subject_metric_files=[f for f in listdir(cur_metric_dir+'/'+subject)]
            print(str(cur_metric))
            for f in subject_metric_files:
                cur_file=open(cur_metric_dir+'/'+subject+'/'+f,'r')
                aggregate_dict[cur_metric].append(json.load(cur_file))
        print("writing output for subject:"+str(subject))
        #all metrics for subject have been processed. Save the subject to aggregate directory.
        outf=open(args.output_dir+"/aggregate_by_subject/"+subject+".json",'w')
        json.dump(aggregate_dict,outf)
        print("Done!:"+subject) 
    
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
    if args.task=="copy_sources":
        return copy_sources(args)
    elif args.task=="group_by_subject":
        return group_by_subject(args)
    elif args.task=="group_by_metric":
        return group_by_metric(args)
    else:
        raise Exception('invalid value specified for --task') 

def main():
    #read in the arguments 
    args=parse_args()

    #perform the specified task
    perform_task(args)
    
    
        
if __name__=="__main__":
    main()
