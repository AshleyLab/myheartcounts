#gets the activity fractions (number of entries for given activity)/total number of entries per day for app version 2
import argparse
from table_parser import *
from aggregators import *
from get_abtest_and_aws_interventions import *
import pickle 
import pdb 
table_parser_choices={"motion_tracker":parse_motion_tracker,
                      "health_kit_data_collector":parse_healthkit_data_collector,
                      "health_kit_sleep_collector":parse_healthkit_sleep_collector,
                      "health_kit_workout_collector":parse_healthkit_workout_collector}
aggregation_choices={"motion_tracker":aggregate_motion_tracker,
                     "health_kit_data_collector":aggregate_healthkit_data_collector,
                     "health_kit_sleep_collector":aggregate_healthkit_data_collector,
                     "health_kit_workout_collector":aggregate_healthkit_data_collector}

def parse_args():
    parser=argparse.ArgumentParser(description="gets the activity fractions (number of entries for given activity)/total number of entries per day for app version 2")
    parser.add_argument("--tables",nargs="+")
    parser.add_argument("--synapseCacheDir")
    parser.add_argument("--out_prefixes",nargs="+")
    parser.add_argument("--subjects",default="all")
    parser.add_argument("--data_types",nargs="+",help="allowed values are \"motion_tracker\",\"health_kit_data_collector\", \"health_kit_sleep_collector\", \"health_kit_workout_collector\" ")
    parser.add_argument("--ab_test",default=None)
    parser.add_argument("--aws_files",default=None) 
    parser.add_argument("--map_aws_to_healthcodes",default=None)
    parser.add_argument("--aws_file_pickle",default=None)
    parser.add_argument("--pickle_dict",default=False) 
    parser.add_argument("--appVersion") 
    parser.add_argument("--intervention_duration",type=int,default=7,help="number of days that each intervention is intended to be applied")
    return parser.parse_args()


def main():
    args=parse_args()
    #make sure the user has provided valid inputs 
    assert len(args.tables)==len(args.data_types)
    assert len(args.tables)==len(args.out_prefixes)
    for data_type in args.data_types:
        assert data_type in table_parser_choices
    assert args.ab_test!=None
    assert args.aws_file_pickle!=None 
    assert args.appVersion!=None 

    #load the intervention metadata 
    interventions=get_interventions(args.ab_test,args.aws_file_pickle,args.appVersion,args.intervention_duration) 
    print("got interventions") 
    #parse all tables 
    for i in range(len(args.tables)):
        #get daily values
        print(str(i))
        subject_daily_vals=table_parser_choices[args.data_types[i]](args.tables[i],args.synapseCacheDir,args.subjects)
        if args.pickle_dict==True: 
            pickle.dump(subject_daily_vals,open(args.out_prefixes[i]+".p",'wb'))
        #aggregate results        
        aggregation_choices[args.data_types[i]](subject_daily_vals,interventions,args.out_prefixes[i])       

if __name__=="__main__":
    main()
    
