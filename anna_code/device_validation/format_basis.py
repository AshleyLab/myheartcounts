#FORMAT BASIS RAW DATA FOR ANALYSIS 
from dateutil.parser import parse
from datetime import * 
import sys 
data=open(sys.argv[1],'r').read().split('\n') 
outf=open(sys.argv[2],'w') 
outf.write("basis_startDate\tbasis_energy\tbasis_gsr\tbasis_hr\tbasis_temp\tbasis_steps\n") 
for line in data[1::]: 
    tokens=line.split(',') 
    if len(tokens)==1: 
        continue 
    ts=parse(tokens[0])
    ts=ts-timedelta(hours=7) #ADJUST FOR TIME ZONE    
    year=str(ts.year) 
    month=str(ts.month)
    if int(month)<10: 
        month='0'+month 
    day=str(ts.day) 
    if int(day)<10: 
        day='0'+day 
    hour=str(ts.hour) 
    if int(hour)<10: 
        hour='0'+hour 
    minute=str(ts.minute) 
    if int(minute) <10: 
        minute='0'+minute
    second=str(ts.second) 
    if int(second)<10: 
        second='0'+second 
    timeentry=str(year)+str(month)+str(day)+str(hour)+str(minute)+str(second)+"-0700"
    outf.write(timeentry+'\t'+'\t'.join(tokens[1::])+'\n') 

    
