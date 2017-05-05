#gets the activity fractions (number of entries for given activity)/total number of entries per day for app version 2
import argparse
from table_parser import *
from aggregators import * 

table_parser_choices={"motion_tracker":parse_motion_tracker,
                      "healthkit_data_collector":parse_healthkit_data_collector}
aggregation_choices={"motion_tracker":aggregate_motion_tracker,
                     "healthkit_data_collector":aggregate_healthkit_data_collector}

def parse_args():
    parser=argparse.ArgumentParser(description="gets the activity fractions (number of entries for given activity)/total number of entries per day for app version 2")
    parser.add_argument("--tables",nargs="+")
    parser.add_argument("--synapseCacheDir")
    parser.add_argument("--out_prefixes",nargs="+")
    parser.add_argument("--subjects",nargs="+",default="all")
    parser.add_argument("--data_types",nargs="+",help="allowed values are \"motion_tracker\",\"health_kit_data_collector\"")
    parser.add_argument("--intervention_metadata")
    return parser.parse_args()

def main():
    args=parse_args()
    #make sure the user has provided valid inputs 
    assert len(args.tables)==len(args.data_types)
    assert len(args.tables)==len(args.out_prefixes)
    for data_type in args.data_types:
        assert data_type in table_parser_choices

    #load the intervention metadata 
    intervention_metadata=load_abtest(args.intervention_metadata)
    days_in_study_dict=dict()
    intervention_order=dict()
    for row in range(len(intervention_metadata)):
        subject=intervention_metadata['healthCode']
        order=intervention_metdata['ABTestResult.variable_value']
        days_in_study=intervention_metadata['ABTestResult.days_in_study']
        days_in_study_dict[subject]=days_in_study
        intervention_order[subject]=intervention_order.split(',')
    print("loaded intervention metdata")

    #parse all tables 
    for i in range(len(args.tables)):
        #get daily values 
        subject_daily_vals=table_parser_choices[args.data_types[i]](args.tables[i],args.synapseCacheDir,args.subjects)
        #aggregate results
        aggregation_choices[args.data_types[i]](subject_daily_vals,days_in_study_dict,intervention_order,args.outf_prefixes[i])       

if __name__=="__main__":
    main()
    
