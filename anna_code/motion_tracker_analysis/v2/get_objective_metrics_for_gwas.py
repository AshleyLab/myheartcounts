#gets summary metrics of motion tracker & health kit data to use as outcomes in gwas analysis
import argparse
import numpy as np
from load_summaries import *
from motion_tracker_metrics import *
from health_kit_metrics import *
import pdb 
metric_motion_tracker_choices={"kmeans_cluster":kmeans_cluster,
                               "percent_of_time_active":percent_of_time_active,
                               "percent_of_time_stationary":percent_of_time_stationary}
metric_health_kit_choices={"mean_step_count":mean_step_count,
                           "mean_distance_walked":mean_distance_walked}

def write_output(all_metrics,subjects,fields,outf):
    outf=open(outf,'w')
    outf.write('Subject\t'+'\t'.join(fields)+'\n')
    for subject in subjects:
        current_line=subject
        for metric in fields:
            if metric in all_metrics[subject]:
                current_line=current_line+'\t'+str(all_metrics[subject][metric])
            else:
                current_line=current_line+'\tNA'
        outf.write(current_line+'\n')
        
def parse_args():
    parser=argparse.ArgumentParser(description="gets summary metrics of motion tracker & health kit data to use as outcomes in gwas analysis")
    parser.add_argument("--source_table_motion_tracker",default=None)
    parser.add_argument("--source_table_health_kit",default=None) 
    parser.add_argument("--metrics_motion_tracker",nargs="*")
    parser.add_argument("--metrics_health_kit",nargs="*")
    parser.add_argument("--outf")
    return parser.parse_args()

def main():
    args=parse_args()
    if args.source_table_motion_tracker!=None:
        motion_tracker_table=load_motion_tracker_summary(args.source_table_motion_tracker)
    if args.source_table_health_kit!=None:
        health_kit_table=load_health_kit_summary(args.source_table_health_kit)
    all_metrics=dict()
    subjects=set([])
    all_fields=[]
    for metric_healthkit in args.metrics_health_kit:        
        assert(metric_healthkit in metric_health_kit_choices)
        print("getting:"+str(metric_healthkit))
        subject_to_value,fields=metric_health_kit_choices[metric_healthkit](health_kit_table)
        all_fields=all_fields+fields 
        for subject in subject_to_value:
            if subject not in all_metrics:
                all_metrics[subject]=subject_to_value[subject]
            else:
                all_metrics[subject].update(subject_to_value[subject])
        subjects=subjects.union(set(subject_to_value.keys()))
            
    for metric_motion_tracker in args.metrics_motion_tracker:
        assert(metric_motion_tracker in metric_motion_tracker_choices)
        print("getting:"+str(metric_motion_tracker))
        subject_to_value,fields=metric_motion_tracker_choices[metric_motion_tracker](motion_tracker_table)
        all_fields=all_fields+fields
        for subject in subject_to_value:
            if subject not in all_metrics:
                all_metrics[subject]=subject_to_value[subject]
            else:
                try:
                    all_metrics[subject].update(subject_to_value[subject])
                except:
                    pdb.set_trace() 
        subjects=subjects.union(set(subject_to_value.keys()))
    #generate the output file
    write_output(all_metrics,subjects,all_fields,args.outf)
    
        
if __name__=="__main__":
    main() 
