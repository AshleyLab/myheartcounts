data=open('../intermediate_results/feature_presence_absence.tsv','r').read().replace('\r\n','\n').split('\n') 
if '' in data: 
    data.remove('') 
header=data[0] 
data=data[1::] 
outf=open('../intermediate_results/feature_groups.tsv','w') 
outf.write(header+'\n') 

patterns=dict() 
for line in data: 
    line=line.split('\t')[1::] 
    line='\t'.join(line) 
    if line in patterns: 
        patterns[line]+=1
    else: 
        patterns[line]=1 
for pattern in patterns: 
    outf.write(str(patterns[pattern])+'\t'+pattern+'\n') 
