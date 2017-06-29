#wrapper script to perform filtering & qc on time series data 
import argparse
from filters import *
from qc_metrics import*

qc_metric_choices={"days_in_study_reported_observed":days_in_study_reported_observed,
                   "missing_intervention_assignment":missing_intervention_assignment}
filter_choices={"min_datapoints":min_datapoints,
                "extract_field":extract_field,
                "account_for_huge_gaps_in_time":account_for_huge_gaps_in_time,
                "extract_field":extract_field}

def parse_args():
    parser=argparse.ArgumentParser("qc and filter aggregate motion/healthkit data")
    parser.add_argument("--data")
    parser.add_argument("--filters",nargs="*",default=[])
    parser.add_argument("--qc_metrics",nargs="*",default=[]) 
    parser.add_argument("--outf_filtered",default=None)
    parser.add_argument("--outf_qc_metrics",nargs="*",default=[])
    parser.add_argument("--intervention_metadata",default=None)
    parser.add_argument("--min_datapoints_thresh",type=int,default=100)
    parser.add_argument("--field_to_extract",default=None) 
    return parser.parse_args()

def main():
    args=parse_args()
    data=open(args.data,'r').read().strip().split('\n')
    #compute the qc metrics
    print("running qc metrics:")
    for qc_metric_index in range(len(args.qc_metrics)):
        cur_qc_metric=args.qc_metrics[qc_metric_index]
        print(cur_qc_metric)
        cur_output_file=args.outf_qc_metrics[qc_metric_index]
        qc_metric_choices[cur_qc_metric](data,cur_output_file)
    print("running filter metrics:")
    #apply the specified filters & write filtered output file 
    for filter_metric_index in range(len(args.filters)):
        cur_filter_metric=args.filters[filter_metric_index]
        print(cur_filter_metric) 
        if cur_filter_metric=="min_datapoints": 
            data=filter_choices[cur_filter_metric](data,args.min_datapoints_thresh)
        elif cur_filter_metric=="extract_field":
            data=filter_choices[cur_filter_metric](data,args.field_to_extract)
        elif cur_filter_metric=="account_for_huge_gaps_in_time":
            data=filter_choices[cur_filter_metric](data,args.intervention_metadata) 
    #write the output file (filtered data file)
    if args.outf_filtered!=None:
        outf=open(args.outf_filtered,'w')
        outf.write('\n'.join(data))
        
    
if __name__=="__main__":
    main()
    
