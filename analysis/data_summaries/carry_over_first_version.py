subjects=open('carry_over_users.txt','r').read().split('\n') 
if '' in subjects: 
    subjects.remove('') 
subset=open('subset','r').read().split('\n') 
if '' in subset: 
    subset.remove('') 

subset_dict=dict() 
for line in subset: 
    line=line.split('\t') 
    subject=line[0] 
    version=line[1] 
    sex=line[2] 
    if sex not in ["Male","Female","Other"]: 
        continue 
    if subject not in subset_dict: 
        subset_dict[subject]=[version] 
    else: 
        subset_dict[subject].append(version) 
outf=open('first_age_sex_info_for_carryover_subjects.txt','w') 
for subject in subjects: 
    if subject not in subset_dict: 
        print str(subject) 
        continue 
    entry=subset_dict[subject] 
    entry.sort() 
    outf.write(subject+'\t'+'\t'.join(entry)+'\n')
