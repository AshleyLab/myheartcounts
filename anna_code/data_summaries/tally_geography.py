source=open('all_subjects_to_offset.txt','r').read().split('\n') 
if '' in source: 
    source.remove('') 
offsets=dict() 
for line in source: 
    line=line.split('\t') 
    if len(line)<2: 
        print str(line) 
        continue 
    date=line[1]
    offset=date[-5::] 
    if offset not in offsets: 
        offsets[offset]=1 
    else: 
        offsets[offset]+=1 
for offset in offsets: 
    print offset+'\t'+str(offsets[offset])
