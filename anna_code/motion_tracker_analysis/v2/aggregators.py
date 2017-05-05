from datetime import datetime,timedelta
from dateutil.parser import parse

#assign day index to applied intervention 
def get_day_index_to_intervention(interventions):
    day_index_to_intervention=dict()
    for day_index in range(7):
        day_index_to_intervention[day_index]="None"
    for day_index in range(7,14):
        day_index_to_intervention[day_index]=interventions[0]
    for day_index in range(14,21):
        day_index_to_intervention[day_index]=interventions[1]
    for day_index in range(21,28):
        day_index_to_intervention[day_index]=interventions[2]
    for day_index in range(28,35):
        day_index_to_intervention[day_index]=interventions[3]
    return day_index_to_intervention

#label each day as a weekend or weekday 
def get_weekday_or_weekend_label(days):
    index_to_type={}
    for i in range(len(days)):
        index_to_type[i]=days[i].weekday()
    return index_to_type


def aggregate_motion_tracker(subject_daily_vals,days_in_study,intervention_order,outf_prefix):
    duration_vals=subject_daily_vals[0]
    fraction_vals=subject_daily_vals[1]
    outf=open(outf_prefix,'w')
    outf.write('Subject\tDaysInStudy\tIntervention\tDayIndex\tDayType\tActivity\tDuration\tFraction\n')
    for subject in duration_vals:
        cur_days_in_study=days_in_study[subject]
        interventions=intervention_order[subject]

        #map day index to the applied intervention 
        day_index_to_intervention=get_day_index_to_intervention(interventions)
        cur_duration_vals=duration_vals[subject]
        cur_fraction_vals=fraction_vals[subject]

        #sort the days!
        subject_days=cur_duration_vals.keys()
        subject_days.sort()

        weekday_or_weekend=get_weekday_or_weekend_label(subject_days)

        first_day=subject_days[0]
        for day in subject_days:
            day_index=(day - first_day).days
            
            #handle the case when the subject has been in the study longer than 35 days 
            if day_index not in day_index_to_intervention:
                cur_intervention=interventions[-1]
            else:
                cur_intervention=day_index_to_intervention[day_index]
            cur_weekday_or_weekend=weekday_or_weekend[day_index]
            for activity in cur_duration_vals[day]:
                cur_activity_duration=cur_duration_vals[day][activity]
                cur_activity_fraction=cur_fraction_vals[day][activity]
                outf.write(subject+\
                           '\t'+str(cur_days_in_study)+\
                           '\t'+str(cur_intervention)+\
                           '\t'+str(day_index)+\
                           '\t'+activity+\
                           '\t'+str(cur_activity_duration)+\
                           '\t'+str(cur_activity_fraction)+\
                           '\n')
            
        
def aggregate_healthkit_data_collector(subject_daily_vals,days_in_study,intervention_order,outf_prefix):
    distance_key='HKQuantityTypeIdentifierDistanceWalk'
    outf=open(outf_prefix,'w')
    outf.write('Subject\tDaysInStudy\tIntervention\tDayIndext\DayType\tDistance\n')
    for subject in duration_vals:
        cur_days_in_study=days_in_study[subject]
        interventions=intervention_order[subject]

        #map day index to the applied intervention 
        day_index_to_intervention=get_day_index_to_intervention(interventions)
        cur_subject_daily_vals=subject_daily_vals[subject]

        #sort the days!
        subject_days=cur_subject_daily_vals.keys()
        subject_days.sort()

        weekday_or_weekend=get_weekday_or_weekend_label(subject_days)
        first_day=subject_days[0]
        for day in subject_days:
            day_index=(day - first_day).days
            
            #handle the case when the subject has been in the study longer than 35 days 
            if day_index not in day_index_to_intervention:
                cur_intervention=interventions[-1]
            else:
                cur_intervention=day_index_to_intervention[day_index]
            cur_weekday_or_weekend=weekday_or_weekend[day_index]
            if distance_key in cur_subject_daily_vals:
                cur_distance=cur_subject_daily_vals[distance_key]
                outf.write(subject+\
                           '\t'+str(cur_days_in_study)+\
                           '\t'+str(cur_intervention)+\
                           '\t'+str(day_index)+\
                           '\t'+cur_distance+\
                           '\n')
    
