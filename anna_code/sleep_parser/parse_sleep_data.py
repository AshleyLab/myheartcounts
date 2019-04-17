#parses healthkit sleep data to extract the following fields:

#1) Mean time to bed
#2) Mean time awake
#3) Mean sleep duration
#4) Mean sleep quality
#5) N entries per subject
#6) Std dev of #1,2,3,4
#7) number sessions per person/day 
import pandas as pd
from dateutil.parser import parse

#parse a single row in either the "sleep" or "bed" dataframe
def parse_row(data_dict,row):
    subject=row['healthCodeId']
    #parse out the date component
    startTime=parse(row['starttime'])
    bedtime_hour=starTime.hour
    waketime=startTime+timedelta(seconds=row['value'])
    waketime_hour=waketime.hour
    duration=row['value']
    sourceId=row['sourceIdentifier']
    session=(bedtime_hour,waketime_hour,duration,sourceId)
    if subject not in data_dict:
        data_dict[subject]=dict()
    if day not in data_dict[subject]:
        data_dict[subject][day]=[session]
    else:
        data_dict[subject][day].append(session)
    return data_dict

def parse_args():
    parser=argparse.ArgumentParser(description="summarize HealthKit Sleep data")
    parser.add_argument("--hk_sleep_df",default="")
    parser.add_argument("--hk_inbed_df",default="")
    parser.add_argument("--outf",default="sleep_data_summary.txt")
    return parser.parse_args()
def main():
    #subject->date 
    sleep_dict=dict()
    inbed_dict=dict() 
    args=parse_args()
    outf=open(args.outf,'w')
    #note: first column is healthCodeId
    sleep_data=pd.read_table(args.hk_sleep_df,header=0,sep='\t',usecols=[0,1,2,3,4,5,6,7])
    bed_data=pd.read_table(args.hk_inbed_df,header=0,sep='\t',usecols=[0,1,2,3,4,5,6,7])
    print("read in datasets")
    for index,row in sleep_data.iterrows():
        parse_row(sleep_dict,row)
    print("parsed the sleep dataframe")
    for index,row in bed_data.iterrows():
        parse_row(inbed_dict,row)
    print("parsed in the inbed dataframe")
    #aggregate per-subject data
    subject_summary=dict()
    device_summary=dict() 
    for subject in sleep_dict.keys():
        #get mean/stdev of values in a session:     session=(bedtime_hour,waketime_hour,duration,sourceId)
        subject_days=[i for i in list(sleep_dict[subject].values())]
        mean_bed_time=[s[0] for s in sleep_dict[subject]
    
        
    
if __name__=="__main__":
    main()
    
