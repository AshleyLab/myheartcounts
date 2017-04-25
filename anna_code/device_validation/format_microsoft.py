#FORMAT MICROSOFT RAW DATA FOR ANALYSIS 
from dateutil.parser import parse
from datetime import timedelta 
import json 
import pickle 
import sys 
import codecs 
data=json.loads(open(sys.argv[1],'r').read())["value"] 
event_dict=dict() #EVENT LEVEL DATA 
minute_dict=dict() #MINUTE LEVEL DATA 
outf_events=open(sys.argv[1]+".EVENTS",'w') 
outf_events.write("EventType\tStartTime\tDuration\tMaximalVO2\tFinishHeartRate\tRecoveryHR1Min\tRecoveryHR2Min\n") 
outf_min=open(sys.argv[1]+".MINUTE",'w') 
outf_min.write("Time\tHR\tEnergy\tSteps\n")

for entry in data: 
    #THIS IS AN EVENT, GET METRICS OF INTEREST 
    event_type=entry["EventType"] 
    event_start=entry["StartTime"] 
    event_duration=entry["Duration"]
    try:
        event_vo2max=entry["MaximalV02"]
    except: 
        event_vo2max="0" 
    event_maxheart=entry["FinishHeartRate"] 
    event_recovery_min1=entry["RecoveryHeartRate1Minute"] 
    event_recovery_min2=entry["RecoveryHeartRate2Minute"]
    
    outf_events.write(str(event_type)+'\t'+str(event_start)+'\t'+str(event_duration)+'\t'+str(event_vo2max)+'\t'+str(event_maxheart)+'\t'+str(event_recovery_min1)+'\t'+str(event_recovery_min2)+'\n')
    #GET MINUTE LEVEL DATA 
    event_info=entry["Info"] 
    for m in event_info: 
        m_time=m["TimeOfDay"]
        m_energy=m["CaloriesBurned"] 
        m_hr=m["AverageHeartRate"] 
        m_steps=m["StepsTaken"] 
        #parse the time into a format we like! 
        m_time=parse(m_time) 
        m_time=m_time-timedelta(hours=7) #ADJUST FOR TIME ZONE    
        year=str(m_time.year) 
        month=str(m_time.month) 
        if int(month)<10: 
            month="0"+month 
        day=str(m_time.day) 
        if int(day)<10: 
            day="0"+day 
        hour=str(m_time.hour) 
        if int(hour) <10: 
            hour="0"+hour 
        minute=str(m_time.minute) 
        if int(minute) < 10: 
            minute="0"+minute 
        second=str(m_time.second) 
        if int(second) < 10: 
            second="0"+second 
        #WRITE TO OUTPUT FILE 
        tp=year+month+day+hour+minute+second+'-0700' 
        outf_min.write(tp+'\t'+str(m_hr)+'\t'+str(m_energy)+'\t'+str(m_steps)+'\n') 
        
        
        
    


