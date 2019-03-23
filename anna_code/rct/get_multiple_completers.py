#find subjects who completed study multiple times 
#the input is a grep of subject & day 0 fields 
#if day 0 occurs multiple times for a subject, they did study twice 
data=open("subject_to_day_0",'r').read().strip().split('\n') 
subject_dict=dict() 
multiple_completers=dict() 
for line in data: 
    subject=line.split('\t')[0]
    if subject not in subject_dict: 
        subject_dict[subject]=1 
    else: 
        if subject not in multiple_completers: 
            multiple_completers[subject]=2 
        else: 
            multiple_completers[subject]+=1 
outf=open('multiple_completers.txt','w') 
for subject in multiple_completers: 
    outf.write(subject+'\t'+str(multiple_completers[subject])+'\n')

