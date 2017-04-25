import statistics
stat_fields=open('stat_fields','r').read().replace('\r\n','\n').split('\n')
stat_fields.remove('')
print(str(stat_fields))

data =open('DataFreezeDataFrame_10022015_VERSION2.txt','r').read().replace('\r','\n').split('\n')
if '' in data: 
    data.remove('')
header=data[0].split('\t')
value_dict=dict()
male_dict=dict()
female_dict=dict()
for line in data[1::]:
    tokens=line.split('\t')
    for i in range(len(header)):
        curvalue=tokens[i]
        if curvalue=="NA":
            continue 
        if curvalue=="TRUE":
            curvalue=1
        elif curvalue=="FALSE":
            curvalue=0
        elif header[i] in stat_fields:
            try:
                curvalue=float(curvalue)
            except:
                continue 
        else:
            #print str(header[i])
            continue
        if header[i] not in value_dict:
            value_dict[header[i]]=[]
            male_dict[header[i]]=[]
            female_dict[header[i]]=[]
        value_dict[header[i]].append(curvalue) 
        if tokens[3]=="Male":
            male_dict[header[i]].append(curvalue)
        if tokens[3]=="Female":
            female_dict[header[i]].append(curvalue)
#get the mean values
allstats=dict()
malestats=dict()
femalestats=dict()

for entry in value_dict:
    values=value_dict[entry]
    meanval=round(statistics.mean(values),3)
    medianval=round(statistics.median(values),3)
    sd=round(statistics.stdev(values),3)
    allstats[entry]=[meanval,medianval,sd]

for entry in male_dict:
    values=male_dict[entry]
    meanval=round(statistics.mean(values),3)
    medianval=round(statistics.median(values),3)
    sd=round(statistics.stdev(values),3)
    malestats[entry]=[meanval,medianval,sd]

for entry in female_dict: 
    values=female_dict[entry]
    meanval=round(statistics.mean(values),3)
    medianval=round(statistics.median(values),3)
    sd=round(statistics.stdev(values),3)
    femalestats[entry]=[meanval,medianval,sd]

outf=open('SummaryStatistics.txt','w')
outf.write('Category\tOverallMean\tOverallMedian\tOverallSD\tMaleMean\tMaleMedian\tMaleSD\tFemaleMean\tFemaleMedian\tFemaleSD\n')
for category in allstats:
    outf.write(category)
    outf.write('\t'+'\t'.join([str(i) for i in allstats[category]]))
    outf.write('\t'+'\t'.join([str(i) for i in malestats[category]]))
    outf.write('\t'+'\t'.join([str(i) for i in femalestats[category]]))
    outf.write('\n')
    
