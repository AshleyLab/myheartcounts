#gets the activity fractions (number of entries for given activity)/total number of entries per day for app version 2
import argparse
from table_loader import *
from synapse_parser import *

def parse_args():
    parser=argparse.ArgumentParser(description="gets the activity fractions (number of entries for given activity)/total number of entries per day for app version 2")
    parser.add_argument("--table",nargs="+")
    parser.add_argument("--metric",default="fraction",help="one of fraction,duration,both")
    parser.add_argument("--synapseCacheDir")
    parser.add_argument("--outf")
    parser.add_argument("--subjects",nargs="+",default="all")
    parser.add_argument("--data_types",nargs="+")
    parser.add_argument("--intervention_metadata")
    return parser.parse_args()

def main():
    args=parse_args()
    intervention_metadata=load_abtest(args.intervention_metadata)
    motionactivity_metdata=load_motion_activity(args.table)
    
    for table in tables:
        

if __name__=="__main__":
    main()
    
