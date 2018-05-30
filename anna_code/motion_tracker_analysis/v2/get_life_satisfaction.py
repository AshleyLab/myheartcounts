import pdb 
satisfaction=open("satisfied_with_life.txt",'r').read().strip().split('\n') 
metadata=open("intervention.metadata",'r').read().strip().split('\n') 
metadata_dict=dict() 
for line in metadata[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    date=tokens[2] 
    if subject not in metadata_dict: 
        metadata_dict[subject]=dict() 
    if date not in metadata_dict[subject]: 
        metadata_dict[subject][date]=line 
#pdb.set_trace() 
print('indexed metadata') 
satisfaction_dict=dict() 
for line in satisfaction[1::]: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    day=tokens[1].split(' ')[0] 
    if subject not in satisfaction_dict: 
        satisfaction_dict[subject]=dict() 
    if day not in satisfaction_dict[subject]: 
        satisfaction_dict[subject][day]='\t'.join(tokens[2::])
#pdb.set_trace() 
print("indexed satisfaction") 
outf=open("satisfaction_with_interventions.txt",'w') 
outf.write("Subject\tIntervention\tDate\tDayIndex\tWorthwhile\tHappy\tWorried\tDepressed\tSatisfied\n")
for subject in satisfaction_dict: 
    if subject not in metadata_dict: 
        continue 
    for dayIndex in satisfaction_dict[subject]: 
        if dayIndex not in metadata_dict[subject]: 
            continue 
        cur_metadata=metadata_dict[subject][dayIndex] 
        cur_satisfaction=satisfaction_dict[subject][dayIndex]
        outf.write(cur_metadata+'\t'+cur_satisfaction+'\n') 

