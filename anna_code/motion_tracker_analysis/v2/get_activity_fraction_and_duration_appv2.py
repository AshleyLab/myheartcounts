#gets the activity fractions (number of entries for given activity)/total number of entries per day for app version 2
import argparse
from table_parser import *
from aggregators import *
from aws_parser import * 
import pickle 
import pdb 
table_parser_choices={"motion_tracker_aws":parse_motion_tracker,
                      "motion_tracker_synapse":parse_motion_tracker,
                      "health_kit_data_collector_aws":parse_healthkit_data_collector,
                      "health_kit_data_collector_synapse":parse_healthkit_data_collector}
aggregation_choices={"motion_tracker_synapse":aggregate_motion_tracker_synapse,
                     "motion_tracker_aws":aggregate_motion_tracker_aws,
                     "health_kit_data_collector_synapse":aggregate_healthkit_data_collector_synapse,
                     "health_kit_data_collector_aws":aggregate_healthkit_data_collector_aws}

def parse_args():
    parser=argparse.ArgumentParser(description="gets the activity fractions (number of entries for given activity)/total number of entries per day for app version 2")
    parser.add_argument("--tables",nargs="+")
    parser.add_argument("--synapseCacheDir")
    parser.add_argument("--out_prefixes",nargs="+")
    parser.add_argument("--subjects",default="all")
    parser.add_argument("--data_types",nargs="+",help="allowed values are \"motion_tracker\",\"health_kit_data_collector\"")
    parser.add_argument("--intervention_metadata",default=None)
    parser.add_argument("--aws_files",default=None) 
    parser.add_argument("--map_aws_to_healthcodes",default=None)
    parser.add_argument("--aws_file_pickle",default=None)
    parser.add_argument("--pickle_dict",default=False) 
    return parser.parse_args()

def get_intervention_metadata_synapse(intervention_metadata): 
    intervention_metadata=load_abtest(intervention_metadata)
    days_in_study_dict=dict()
    intervention_order=dict()
    for row in range(len(intervention_metadata)):
        subject=intervention_metadata['healthCode'][row]
        order=intervention_metadata['ABTestResultvariable_value'][row]
        days_in_study=intervention_metadata['ABTestResultdays_in_study'][row]
        days_in_study_dict[subject]=days_in_study
        intervention_order[subject]=order.split(',')
    return days_in_study_dict,intervention_order


def get_intervention_metadata_aws(aws_file_pickle,aws_files,aws_map_aws_to_healthcodes): 
    days_in_study_dict=dict() 
    intervention_order=dict() 
    #if a pickle was provided, load the dictionary directly from the pickle. 
    if (aws_file_pickle!=None): 
        #subject->day->set of interventions observed on that day 
        intervention_order_dict=pickle.load(open(aws_file_pickle,'rb'))
    #if no pickle was provided,read data in 
    else:
        client_id_to_health_code_id=map_aws_to_healthcode(aws_map_aws_to_healthcodes)
        intervention_order=extract_interventions(aws_files,client_id_to_health_code_id)
        #pickle this dictionray, it takes a long time to generate 
        pickle.dump(intervention_order,open(aws_files+'.p','wb'))
    for subject in intervention_order_dict: 
        days_in_study_dict[subject]=len(intervention_order_dict.values()) 
    return days_in_study_dict,intervention_order


def main():
    args=parse_args()
    #make sure the user has provided valid inputs 
    assert len(args.tables)==len(args.data_types)
    assert len(args.tables)==len(args.out_prefixes)
    for data_type in args.data_types:
        assert data_type in table_parser_choices
    if args.intervention_metadata==None: 
        if args.aws_file_pickle==None: 
            assert ((args.aws_files!=None) and (args.map_aws_to_healthcodes!=None))            
   
    #load the intervention metadata 
    if (args.intervention_metadata!=None):
        days_in_study_dict,intervention_order = get_intervention_metadata_synapse(args.intervention_metadata) 
    else:
        days_in_studydict,intervention_order=get_intervention_metadata_aws(args.aws_file_pickle,args.aws_files,args.map_aws_to_healthcodes)

    #parse all tables 
    for i in range(len(args.tables)):
        #get daily values
        print(str(i))
        subject_daily_vals=table_parser_choices[args.data_types[i]](args.tables[i],args.synapseCacheDir,args.subjects)
        if args.pickle_dict==True: 
            pickle.dump(subject_daily_vals,open(args.out_prefixes[i]+".p",'wb'))
        #aggregate results        
        aggregation_choices[args.data_types[i]](subject_daily_vals,days_in_study_dict,intervention_order,args.out_prefixes[i])       

if __name__=="__main__":
    main()
    
