base="/home/annashch/6min_walk.tsvf" 
outf=open('../intermediate_results/6minute_merged.tsv','w') 
subject_dict=dict() 
for i in range(0,20): 
    data=open(base+str(i)+'.tsv','r').read().split('\n') 
    if '' in data:
        data.remove('') 
    header=data[0]
    data=data[1::] 
    for line in data: 
        line=line.split('\t') 
        subject=line[0] 
        if subject not in subject_dict: 
            subject_dict[subject]=[line[1::]] 
        else: 
            subject_dict[subject].append(line[1::]) 

outf.write(header+'\n') 
for subject in subject_dict: 
    #print str(subject_dict[subject]) 

    min_na=100
    best=["NA"]*(len(header)-1)
    for entry in subject_dict[subject]: 
        na_count=entry.count('NA') 
        if na_count < min_na: 
            min_na=na_count 
            best=entry
            print str(best) 
    outf.write(subject+'\t'+'\t'.join(best)+'\n') 

            
