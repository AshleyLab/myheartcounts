dirname="/home/anna/6minute_walk/hr_rest/"
import os 
from os import listdir 
from os.path import isfile,join
import codecs
files=[f for f in listdir(dirname) if isfile(join(dirname,f))]
#{u'startDate': u'2015-03-17T10:02:22-0500', u'endDate': u'2015-03-17T10:02:22-0500', u'value': 98, u'source': u'Polar H7 26ABD2', u'type': u'HKQuantityTypeIdentifierHeartRate', u'unit': u'count/min'}
header="startDate\tendDate\tvalue\tsource\tunit\n"
for f in files:
    data=open(dirname+f,'r').read().split('\n')
    data=[i.replace("u'","") for i in data]
    data=[i.replace('u"',"") for i in data]
    data=[i.replace('{','') for i in data]
    data=[i.replace('}','') for i in data] 
    data=[i.replace("'","") for i in data]
    data=[i.replace('"','') for i in data]
    data=[i.replace("\\xa0"," ") for i in data] 
    data.remove('') 
    outf=open('/home/anna/6minute_walk/fixed_hr_rest/'+f,'w')
    outf.write(header) 
    for line in data:
        entries=[] 
        line=line.split(', ')
        print str(line) 
        for entry in line:
            entries.append(entry.split(': ')[1])
        outf.write(entries[0]+'\t'+entries[1]+'\t'+entries[2]+'\t'+entries[3]+'\t'+entries[5]+'\n')
        
            
            
