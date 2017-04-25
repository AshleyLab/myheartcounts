hk=open("HR_for_Activity_State.tsv",'r').read().split('\n') 
while '' in hk: 
    hk.remove('') 
cv=open("HR_for_Activity_State_CV.tsv","r").read().split('\n') 
while '' in cv: 
    cv.remove('') 
merged=dict() 
not_na=set([]) 
hk_header=hk[0].split('\t') 
for line in hk[1::]: 
    line=line.split('\t') 
    subject=line[0] 
    subject_vals=set(line[1::]) 
    if len(subject_vals)==1: 
        continue 
    merged[subject]=dict() 
    for i in range(1,len(line)): 
        field=hk_header[i] 
        val=line[i] 
        if val!="NA": 
            not_na.add(field) 
        merged[subject][field]=val 
cv_header=cv[0].split('\t') 
for line in cv[1::]: 
    line=line.split('\t') 
    subject=line[0] 
    subject_vals=set(line[1::]) 
    if len(subject_vals)==1: 
        continue 
    if subject not in merged: 
        merged[subject]=dict() 
    for i in range(1,len(line)): 
        field=cv_header[i] 
        val=line[i] 
        if val!="NA": 
            not_na.add(field) 
        merged[subject][field]=val 

fields=list(not_na) 
outf=open('HR_for_Acitivty_State_MERGED.tsv','w') 
outf.write('Subject\t'+'\t'.join(fields)+'\n')  
for subject in merged: 
    outf.write(subject) 
    for field in fields: 
        if field in merged[subject]: 
            outf.write('\t'+str(merged[subject][field]))
        else: 
            outf.write('\tNA')
    outf.write('\n') 
