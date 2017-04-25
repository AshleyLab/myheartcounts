import sys 
import datetime
data=open(sys.argv[1],'r').read().split('\n') 
while '' in data: 
    data.remove('') 
outf=open(sys.argv[2],'w') 
outf.write('Date\tHeartRate\n')
for line in data: 
    tokens=line.split('\t') 
    ts=tokens[0] 
    ts=ts.split(':')[0:2] 
    ts=':'.join(ts)
    ts=datetime.datetime.strptime(ts,'%Y-%m-%dT%H:%M')
    ts=ts-datetime.timedelta(hours=8) 
    ts=datetime.datetime.strftime(ts,"%Y%m%d%H%M")
    outf.write(ts+'00-0700'+'\t'+tokens[1]+'\n')

