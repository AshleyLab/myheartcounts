
data=open('/home/annashch/filtered_summary.txt','r').read().split('\n') 
#data=open('/home/annashch/card_disp_summary.tsv','r').read().split('\n') 
data.remove('') 
subjects=open('/home/annashch/subjects.txt','r').read().split('\n') 
if '' in subjects: 
    subjects.remove('') 


header=data[0].split('\t')
numentries=len(header)-1 
filler="\tNA"*numentries 

outf=open('/home/annashch/filtered_summary_augmented.tsv','w') 
#outf=open('/home/annashch/card_disp_summary_augmented.tsv','w') 
outf.write(data[0]+'\n') 

data_dict=dict() 
for line in data[1::]: 
    subject=line.split('\t')[0] 
    data_dict[subject]=line 

for s in subjects: 
    if s in data_dict: 
        outf.write(data_dict[s]+'\n') 
    else: 
        outf.write(s+filler+'\n') 
