data=open('cardiovascular-NonIdentifiableDemographicsTask-v2.tsv.NODUPLICATES','r').read().split('\n') 
if '' in data: 
    data.remove('') 

outf=open('filtered.txt','w') 
subjects=dict() 
for line in data: 
    tokens=line.split('\t') 
    subject=tokens[2] 
    if subject not in subjects: 
        outf.write(line+'\n') 
        subjects[subject]=1 
    else: 
        continue 
