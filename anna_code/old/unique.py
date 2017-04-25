data=open('/home/annashch/sorted_tables/satisfied3','r').read().split('\n') 
if '' in data: 
    data.remove('') 
outf=open('/home/annashch/intermediate_results/survey_satisfied.tsv','w')
outf.write(data[0]+'\n') 

subject_dict=dict()  
for line in data[1::]: 
    subject=line.split('\t')[0] 
    subject_dict[subject]=line 
for subject in subject_dict: 
    outf.write(subject_dict[subject]+'\n') 
