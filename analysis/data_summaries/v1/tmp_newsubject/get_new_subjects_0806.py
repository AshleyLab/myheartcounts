data=open('all.columns.notna','r').read().split('\n') 
data.remove('') 
outf=open('newsubjects','w')
entries=dict() 
for line in data: 
    line=line.split('\t') 
    subject=line[0] 
    timestamp=line[1] 
    if subject not in entries: 
        entries[subject]=[timestamp] 
    else: 
        entries[subject].append(timestamp) 

for subject in entries: 
    timestamps=entries[subject] 
    timestamps.sort() 
    outf.write(subject+'\t'+str(timestamps[0])+'\n')

