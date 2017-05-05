from datetime import datetime,timedelta
from dateutil.parser import parse

def aggregate_motion_tracker(subject_daily_vals,days_in_study,intervention_order,outf_prefix):
    duration_vals=subject_daily_vals[0]
    fraction_vals=subject_daily_vals[1]
    outf=open(outf_prefix,'w')
    outf.write('Subject\tDaysInStudy\tIntervention\tDayIndex\tDayType\tActivity\tDuration\tFraction\n')
    
def aggregate_healthkit_data_collector(subject_daily_vals,days_in_study,intervention_order,outf_prefix):
    distance_key='HKQuantityTypeIdentifierDistanceWalk'
    outf=open(outf_prefix,'w')
    outf.write('Subject\tDaysInStudy\tIntervention\tDayIndext\DayType\tDistance\n')
    
