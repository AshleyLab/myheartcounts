from dateutil.parser import parse
def parse_csv(data):
        print "parsing CSV"
        while '' in data:
                data.remove('') 
        #print str(data)
        entries=0
        timestart=0
        timeend=0
        lastentry=None
        granularity=[] 
        unknowns=0
        if len(data)>1:
                print "newline separate format" 
                #the '\n' delimiter is correct
                entries=len(data)-1 #subtract one to account for header
                firsttime=data[1].split(',')[0].replace(' amZ','-05:00').replace(' pmZ','-05:00')
                firsttime=firsttime.lstrip('0') 
                firsttime=parse(firsttime) 
                timestart=(firsttime-parse('2000-01-01T00:00:00-05:00')).total_seconds()
                lasttime=data[-1].split(',')[0].replace(' amZ','-05:00').replace(' pmZ','-05:00')
                lasttime=lasttime.lstrip('0')
                lasttime=parse(lasttime)
                timeend=(lasttime-parse('2000-01-01T00:00:00-05:00')).total_seconds()
                for line in data[1::]:
                        line=line.split(',')
                        if len(line)==1:
                                continue 
                        if line[1]=="unknown":
                                unknowns+=1
                        curtime=line[0].replace(' amZ','-05:00').replace(' pmZ','-05:00')
                        curtime=curtime.lstrip('0')
                        print str(curtime)
                        curtime=parse(curtime) 
                        if lastentry!=None:
                                try:
                                        granularity.append((curtime-lastentry).total_seconds())
                                except:
                                        lastentry=curtime
                                        
                        lastentry=curtime 
        elif data[0].__contains__('{'):
                #this is a json file, use ',' as the delimiter rather than '\n'
                print "json format" 
                data=data[0]
                data=data.replace('}','')
                data=data.replace('[','')
                data=data.replace(']','')
                data=data.split('{')
                entries=len(data)
                timestart=float(data[0].split(',')[1].split(':')[1])
                timeend=float(data[1].split(',')[1].split(':')[1]) 
                for line in data:
                        curtime=float(line.slpit(',')[1].split(':')[1])
                        if lastentry!=None:
                                granularity.append((curtime-lastentry).total_seconds())
                        lastentry=curtime 
        timespan=timeend-timestart
        granularity=sum(granularity)/float(len(granularity))
        return entries,timespan,granularity,unknowns 

data=open('/home/common/myheart/data/synapseCache/718/2322718/data.csv-ed441de8-a0c7-461b-a844-afa03ae8d2d85376808272544071356.tmp','r').read().replace('\r\n','\n').split('\n')
while '' in data:
    data.remove('')
entries,timespan,granularity,unknowns=parse_csv(data)
print "entries:"+str(entries)
print "timespan:"+str(timespan)
print "granularity:"+str(granularity)
print "unknowns:"+str(unknowns)


    
