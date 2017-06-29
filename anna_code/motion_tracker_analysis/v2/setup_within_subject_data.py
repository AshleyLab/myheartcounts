import argparse
from loadk_summaries import *

def parse_args():
    parser=argparse.ArgumentParser(description="generate inputs for each intervention to perform a paired t test")
    parser.add_argument('--source_data_frame')
    parser.add_argument('--out_prefix')
    parser.add_argument('--data_type',help='one of healthkit or motiontracker')
    parser.add_argument('--duration',default=False)
    parser.add_argument('--fraction',default=True)
    parser.add_argument('--activity',nargs="+",help="you can sum across multiple activities") 
    return parser.parse_args()

def main():
    args=parse_args()
    assert args.data_type in ['healthkit','motiontracker'] 
    if args.data_type=="healthkit":
        data=load_health_kit_summary(args.source_data_frame)
    else:
        data=load_motion_tracker_summary(args.source_data_frame)
    intervention_dict=dict()
    for row in range(len(data)):
        cur_subject=data['Subject'][row]
        cur_intervention=data['Intervention'][row]
        cur_

if __name__=="__main__":
    main()
    
