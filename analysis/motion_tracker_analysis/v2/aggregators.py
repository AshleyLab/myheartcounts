from datetime import datetime,timedelta
from dateutil.parser import parse
import pdb 



def aggregate_motion_tracker(subject_daily_vals,interventions,outf_prefix): 
    duration_vals=subject_daily_vals[0]
    fraction_vals=subject_daily_vals[1]
    numentries_vals=subject_daily_vals[2]
    
    outf=open(outf_prefix,'w')
    outf.write('Subject\tDate\tWeekday\tappVersion\tABTest\tAWS\tActivity\tDuration_in_Minutes\tFraction\tNumentries\tSourceBlobs\n')
    for subject in duration_vals: 
        for day in duration_vals[subject]: 
            cur_weekday=day.weekday() 
            try:
                cur_appversion=interventions[subject][day]['appVersion'] 
            except: 
                cur_appversion="NONE"
            try:
                cur_abtest=interventions[subject][day]['ABTest'] 
            except: 
                cur_abtest="NONE" 
            try:
                cur_aws=interventions[subject][day]['AWS'] 
            except: 
                cur_aws="NONE"            
            numentries=numentries_vals[subject][day]
            for activity in duration_vals[subject][day]: 
                #sum durations across blobs 
                blobs=','.join([str(i) for i in duration_vals[subject][day][activity].keys()])
                #get the duration in minutes 
                duration=sum([i.total_seconds() for i in duration_vals[subject][day][activity].values()])/60
                fraction=0 
                if activity in fraction_vals[subject][day]: 
                    fraction=sum([i for i in fraction_vals[subject][day][activity].values()])
                outf.write(subject+'\t'+
                           str(day)+'\t'+
                           str(cur_weekday)+'\t'+
                           str(cur_abtest)+'\t'+
                           str(cur_aws)+'\t'+
                           activity+'\t'+
                           str(duration)+'\t'+
                           str(fraction)+'\t'+
                           str(numentries)+'\t'+
                           str(blobs)+'\n')
                
                    
def aggregate_healthkit_data_collector(subject_daily_vals,interventions,outf_prefix):
    outf=open(outf_prefix,'w')
    outf.write("Subject\tDate\tWeekDay\tappVersion\tABTest\tAWS\tMetric\tValue\tSource\tSourceBlobs\n")
    for subject in subject_daily_vals: 
        for day in subject_daily_vals[subject]: 
            cur_weekday=day.weekday() 
            try:
                cur_appversion=interventions[subject][day]['appVersion'] 
            except: 
                cur_appversion="NONE"
            try:
                cur_abtest=interventions[subject][day]['ABTest'] 
            except: 
                cur_abtest="NONE" 
            try:
                cur_aws=interventions[subject][day]['AWS'] 
            except: 
                cur_aws="NONE"
            for metric in subject_daily_vals[subject][day]: 
                for source in subject_daily_vals[subject][day][metric]: 
                    blobs=','.join([str(i) for i in subject_daily_vals[subject][day][metric][source].keys()])
                    value=sum([i for i in subject_daily_vals[subject][day][metric][source].values()])
                    outf.write(subject+'\t'+
                               str(day)+'\t'+
                               str(cur_weekday)+'\t'+
                               str(cur_appversion)+'\t'+
                               str(cur_abtest)+'\t'+
                               str(cur_aws)+'\t'+
                               str(metric)+'\t'+
                               str(value)+'\t'+
                               str(source)+'\t'+
                               str(blobs)+'\n')


