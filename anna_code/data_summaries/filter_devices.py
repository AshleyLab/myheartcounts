data=open('devices','r').read().split('\n') 
if '' in data: 
    data.remove('') 
outf=open('devices.filtered','w') 
for line in data: 
    print str(line) 
    tokens=line.split('\t') 
    if tokens[0].startswith('com.apple.health'): 
        continue
    if len(tokens)==2: 
        if tokens[1] in ["count","kg","m","seconds asleep","mmHg","mg/dL","seconds in bed","count/s"]: 
            continue 
    outf.write(line+'\n') 
