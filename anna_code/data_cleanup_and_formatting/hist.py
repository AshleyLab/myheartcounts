data=open('uploads.version','r').read().split('\n') 
data.remove('') 
counts=dict() 
for line in data: 
    line=line.split('\t') 
    version=line[1] 
    date=line[0] 
    if version not in counts: 
        counts[version]=dict() 
    if date not in counts[version]: 
        counts[version][date]=1
    else: 
        counts[version][date]+=1 
outf=open('uploads.counts.version','w') 
for entry in counts:
    for date in counts[entry]: 
        outf.write(entry+'\t'+date+'\t'+str(counts[entry][date])+'\n')

