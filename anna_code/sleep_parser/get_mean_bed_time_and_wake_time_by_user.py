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
from datetime import timedelta 
import pdb
import argparse
import numpy as np 
#parse a single row in either the "sleep" or "bed" dataframe
def parse_row(data_dict,row):
    subject=row['healthCode']
    #parse out the date component
    try:
        startTime=parse(row['startTime'])
    except:
        print(str(row))
        return data_dict 
    day=startTime.date() 
    bedtime_hour=startTime.hour
    waketime=startTime+timedelta(seconds=row['value'])
    waketime_hour=waketime.hour
    duration=row['value']
    sourceId=row['sourceIdentifier']
    sourceDevice=row['source'] 
    session=(bedtime_hour,waketime_hour,duration,sourceId,sourceDevice)
    if subject not in data_dict:
        data_dict[subject]=dict()
    if day not in data_dict[subject]:
        data_dict[subject][day]=[session]
    else:
        data_dict[subject][day].append(session)
    return data_dict

def parse_args():
    parser=argparse.ArgumentParser(description="summarize HealthKit Sleep data")
    parser.add_argument("--hk_sleep_df",default="out.HKCategoryValueSleepAnalysisAsleep")
    parser.add_argument("--hk_inbed_df",default="out.HKCategoryValueSleepAnalysisInBed")
    parser.add_argument("--outf_prefix",default="sleep_data_summary")
    return parser.parse_args()

def main():
    #subject->date 
    sleep_dict=dict()
    inbed_dict=dict() 
    args=parse_args()
    outf_subjects=open(args.outf_prefix+".subjects.txt",'w')
    outf_devices=open(args.outf_prefix+".devices.txt",'w') 
    outf_apps=open(args.outf_prefix+'.apps.txt','w')
    subject_header=['Subject','MeanTimeToBed','StdTimeToBed','MeanTimeAwake','StdTimeAwake','MeanSleepDuration','StdSleepDuration','MeanSleepQuality','StdSleepQuality','NDays','MeanSessionsPerDay','StdSessionsPerDay','SourceApps','SourceDevices']
    outf_subjects.write('\t'.join(subject_header)+'\n')
    device_header=['Device','Individuals','PersonDays']
    app_header=['App','Individuals','PersonDays']
    outf_devices.write('\t'.join(device_header)+'\n')
    outf_devices.write('\t'.join(app_header)+'\n') 
    #note: first column is healthCode
    sleep_data=pd.read_csv(args.hk_sleep_df,header=0,sep='\t',usecols=[0,1,2,3,4,5,6,7])
    bed_data=pd.read_csv(args.hk_inbed_df,header=0,sep='\t',usecols=[0,1,2,3,4,5,6,7])
    print("read in datasets")
    for index,row in sleep_data.iterrows():
        sleep_dict=parse_row(sleep_dict,row)
    print("parsed the sleep dataframe")
    for index,row in bed_data.iterrows():
        inbed_dict=parse_row(inbed_dict,row)
    print("parsed in the inbed dataframe")
    #aggregate per-subject data
    subject_summary=dict()
    device_summary=dict()
    app_summary=dict() 
    for subject in sleep_dict.keys():
        #1) Mean time to bed
        #2) Mean time awake
        #3) Mean sleep duration
        #4) Mean sleep quality
        #5) N entries per subject
        #6) Std dev of #1,2,3,4
        #7) number sessions per person/day

        #(bedtime_hour,waketime_hour,duration,sourceId)
        num_entries=[]
        bedtime_hour=[]
        waketime_hour=[]
        duration=[]
        sourceApps=[]
        sourceDevices=[] 
        fraction_asleep=[]
        num_days=len(sleep_dict[subject].values())
        for curDate in sleep_dict[subject]:
            cur_values=sleep_dict[subject][curDate]
            num_entries.append(len(cur_values))
            for session in cur_values:
                session_bedtime_hour=session[0]
                session_waketime_hour=session[1]
                session_duration=session[2]
                session_sourceApp=session[3]
                session_sourceDevice=session[4] 
                bedtime_hour.append(session_bedtime_hour)
                waketime_hour.append(session_waketime_hour)
                duration.append(session_duration)
                sourceApps.append(session_sourceApp)
                sourceDevices.append(session_sourceDevice)
                
                #get the sleep quality metric for this session, if corresponding entry exists in the "InBed" dictionary
                if subject in inbed_dict:
                    if curDate in inbed_dict[subject]:
                        for b_session in inbed_dict[subject][curDate]:
                            if b_session[0]<=session_bedtime_hour:
                                if b_session[1]>=session_waketime_hour:
                                    b_duration=b_session[2]
                                    assert session_duration <= session_duration 
                                    cur_fraction_asleep=session_duration/b_duration
                                    fraction_asleep.append(cur_fraction_asleep)
        mean_bedtime_hour=sum(bedtime_hour)/len(bedtime_hour)
        mean_waketime_hour=sum(waketime_hour)/len(waketime_hour)
        mean_duration=sum(duration)/len(duration)
        if len(fraction_asleep)==0: 
            mean_fraction_asleep=0
        else: 
            mean_fraction_asleep=sum(fraction_asleep)/len(fraction_asleep)
        if len(num_entries)==0: 
            mean_num_entries=0
        else: 
            mean_num_entries=sum(num_entries)/len(num_entries)

        sd_bedtime_hour=np.std(bedtime_hour)
        sd_waketime_hour=np.std(duration)
        sd_duration=np.std(duration)
        sd_fraction_asleep=np.std(fraction_asleep)
        sd_num_entries=np.std(num_entries)
        #tally up the sourceApps and sourceDevices
        sourceApp_dict=dict()
        sourceDevice_dict=dict() 
        for sourceApp in sourceApps: 
            if sourceApp not in sourceApp_dict:  
                sourceApp_dict[sourceApp]=1 
            else: 
                sourceApp_dict[sourceApp]+=1 
        for sourceDevice in sourceDevices: 
            if sourceDevice not in sourceDevice_dict: 
                sourceDevice_dict[sourceDevice]=1 
            else: 
                sourceDevice_dict[sourceDevice]+=1 
            
        for source in sourceDevice_dict: 
            if source not in device_summary: 
                device_summary[source]=dict() 
            if 'subject_days' not in device_summary[source]: 
                device_summary[source]['subject_days']=sourceDevice_dict[source]
            else: 
                device_summary[source]['subject_days']+=sourceDevice_dict[source] 
            if 'subjects' not in device_summary[source]: 
                device_summary[source]['subjects']=1
            else: 
                device_summary[source]['subjects']+=1 
        for source in sourceApp_dict: 
            if source not in app_summary: 
                app_summary[source]=dict() 
            if 'subject_days' not in app_summary[source]: 
                app_summary[source]['subject_days']=sourceApp_dict[source]
            else: 
                app_summary[source]['subject_days']+=sourceApp_dict[source] 
            if 'subjects' not in app_summary[source]: 
                app_summary[source]['subjects']=1
            else: 
                app_summary[source]['subjects']+=1 
        #write outputs to summary file
        out_line=[subject,mean_bedtime_hour,sd_bedtime_hour,mean_waketime_hour,sd_waketime_hour, mean_duration, sd_duration, mean_fraction_asleep, sd_fraction_asleep, num_days, mean_num_entries, sd_num_entries, ','.join(list(sourceApp_dict.keys())),','.join(list(sourceDevice_dict.keys()))]        
        out_line='\t'.join([str(i) for i in out_line])
        outf_subjects.write(out_line+'\n')
    #summarize device data     
    print("summarizing device-specific data") 
    for device in device_summary: 
        outf_devices.write(device+'\t'+str(device_summary[device]['subjects'])+'\t'+str(device_summary[device]['subject_days'])+'\n')
    print("summarizing app-sepcific data") 
    for app in app_summary: 
        outf_apps.write(app+'\t'+str(app_summary[app]['subjects'])+'\t'+str(app_summary[app]['subject_days'])+'\n')

if __name__=="__main__":
    main()
    
