#SPLITS  TABLES INTO CHUNKS OF 50 SUBJECTS SO THAT PARALLEL CONCAT SCRIPTS CAN BE EXECUTED ON SCG3 
from Parameters import * 
chunk_size=50 

#6 MINUTE WALK ! 
summary_table=open(table_dir+walk_file).read().replace('\r\n','\n').split('\n') 
summary_table=summary_table[1::]
while '' in summary_table: 
    summary_table.remove('') 

subject_dict=dict() 
for line in summary_table: 
    #print str(line) 
    subject=line.split('\t')[2] 
    if subject not in subject_dict: 
        subject_dict[subject]=[line] 
    else: 
        subject_dict[subject].append(line) 
num_subject=len(subject_dict.keys()) 
chunks=num_subject/chunk_size+1 # no more than 1 subject to be processed in one go 
subjects=subject_dict.keys() 
for i in range(chunks): 
    sliced=subjects[i*chunk_size:(i+1)*chunk_size]
    outf=open(walk_subsets+"subset_"+str(i+1),'w')
    for s in sliced: 
        entries=subject_dict[s]
        outf.write('\n'.join(entries)+'\n')

#MOTION TRACKER 
summary_tables=motiontracker_files 
for t in summary_tables: 
    summary_table=open(table_dir+t).read().replace('\r\n','\n').split('\n') 
    summary_table=summary_table[1::] 
    while '' in summary_table: 
        summary_table.remove('') 
    subject_dict=dict() 
    for line in summary_table: 
        #print str(line) 
        subject=line.split('\t')[2] 
        if subject not in subject_dict: 
            subject_dict[subject]=[line] 
        else: 
            subject_dict[subject].append(line) 
    num_subject=len(subject_dict.keys()) 
    chunks=num_subject/chunk_size+1 # no more than 1 subject to be processed in one go 
    subjects=subject_dict.keys() 
    for i in range(chunks): 
        sliced=subjects[i*chunk_size:(i+1)*chunk_size]
        outf=open(motiontracker_subsets+t+"_"+str(i+1),'w')
        for s in sliced: 
            entries=subject_dict[s]
            outf.write('\n'.join(entries)+'\n')

#HEALTH KIT 
summary_tables=healthkit_files 
for t in summary_tables: 
    summary_table=open(table_dir+t).read().replace('\r\n','\n').split('\n') 
    summary_table=summary_table[1::] 
    while '' in summary_table: 
        summary_table.remove('') 
    subject_dict=dict() 
    for line in summary_table: 
        #print str(line) 
        subject=line.split('\t')[2] 
        if subject not in subject_dict: 
            subject_dict[subject]=[line] 
        else: 
            subject_dict[subject].append(line) 
    num_subject=len(subject_dict.keys()) 
    chunks=num_subject/chunk_size+1 # no more than 1 subject to be processed in one go 
    subjects=subject_dict.keys() 
    for i in range(chunks): 
        sliced=subjects[i*chunk_size:(i+1)*chunk_size]
        outf=open(healthkit_subsets+t+"_"+str(i+1),'w')
        for s in sliced: 
            entries=subject_dict[s]
            outf.write('\n'.join(entries)+'\n')

#CARDIOVASCULAR DISPLACEMENT 
summary_tables=cardio_disp_files 
for t in summary_tables: 
    summary_table=open(table_dir+t).read().replace('\r\n','\n').split('\n') 
    summary_table=summary_table[1::] 
    while '' in summary_table: 
        summary_table.remove('') 
    subject_dict=dict() 
    for line in summary_table: 
        #print str(line) 
        subject=line.split('\t')[2] 
        if subject not in subject_dict: 
            subject_dict[subject]=[line] 
        else: 
            subject_dict[subject].append(line) 
    num_subject=len(subject_dict.keys()) 
    chunks=num_subject/chunk_size+1 # no more than 1 subject to be processed in one go 
    subjects=subject_dict.keys() 
    for i in range(chunks): 
        sliced=subjects[i*chunk_size:(i+1)*chunk_size]
        outf=open(cardio_disp_subsets+t+"_"+str(i+1),'w')
        for s in sliced: 
            entries=subject_dict[s]
            outf.write('\n'.join(entries)+'\n')
