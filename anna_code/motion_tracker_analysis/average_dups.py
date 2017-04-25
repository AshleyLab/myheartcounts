from operator import add 
data=open('TOTAL.sorted','r').read().split('\n') 
header=data[0] 
outf=open('TOTAL_nodups','w') 
outf.write(header+'\n') 
subjects=dict() 
totals=dict() 
for line in data[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    values=[float(i) for i in tokens[1::]]
    if subject not in subjects: 
        subjects[subject]=values 
        totals[subject]=1 
    else: 
        oldvals=subjects[subject]
        newvals=map(add,oldvals,values) 
        subjects[subject]=newvals 
        totals[subject]+=1 
#get the averages: 
for subject in subjects: 
    s_total=totals[subject] 
    s_vals=subjects[subject] 
    averaged=[(1.0/s_total)*i for i in s_vals]
    outf.write(subject+'\t'+'\t'.join([str(i) for i in averaged])+'\n')

