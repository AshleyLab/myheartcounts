#FORMAT FITBIT RAW DATA FOR ANALYSIS 
from dateutil.parser import parse
from datetime import * 
import sys 
data=open(sys.argv[1],'r').read().split('\n') 
outf=open(sys.argv[2],'w') 
outf.write('Date\theart\tcalories\tsteps\n')
date_to_vals=dict() 
#NEED TO ALIGN DATES FOR THE HR, ENERGY, STEPS data streams 
for line in data[1::]: 
    tokens=line.split('\t') 
    if len(tokens)==1: 
        continue 
    try:
        date_hr=parse(tokens[0]) 
        if date_hr not in date_to_vals: 
            date_to_vals[date_hr]=dict() 
        hr=tokens[1] 
        date_to_vals[date_hr]['hr']=hr 
    except: 
        pass
    try:
        date_cal=parse(tokens[2]) 
        cal=tokens[3] 
        if date_cal not in date_to_vals: 
            date_to_vals[date_cal]=dict() 
        date_to_vals[date_cal]['cal']=cal 
    except: 
        pass
    try:
        date_steps=parse(tokens[4]) 
        steps=tokens[5] 
        if date_steps not in date_to_vals: 
            date_to_vals[date_steps]=dict() 
        date_to_vals[date_steps]['steps']=steps 
    except: 
        pass 
print str(date_to_vals) 
keys=date_to_vals.keys() 
keys.sort() 

for date in keys: 
    #format the date 
    year=str(date.year) 
    month=str(date.month) 
    if int(month) < 10: 
        month='0'+str(month) 
    day=str(date.day) 
    if int(day)< 10: 
        day='0'+day 
    hour=str(date.hour) 
    if int(hour)<10: 
        hour='0'+hour 
    minute = str(date.minute) 
    if int(minute) < 10: 
        minute='0'+minute 
    second=str(date.second) 
    if int(second)<10: 
        second='0'+second 
    outf.write(year+month+day+hour+minute+second+'-0700') 
    if 'hr' in date_to_vals[date]: 
        outf.write('\t'+str(date_to_vals[date]['hr']))
    else: 
        outf.write('\t') 
    if 'cal' in date_to_vals[date]: 
        outf.write('\t'+str(date_to_vals[date]['cal']))
    else: 
        outf.write('\t') 
    if 'steps' in date_to_vals[date]: 
        outf.write('\t'+str(date_to_vals[date]['steps']))
    else: 
        outf.write('\t') 
    outf.write('\n') 

    
