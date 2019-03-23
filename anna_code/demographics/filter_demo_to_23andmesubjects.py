subjects23andme=open('23andme.subjects','r').read().strip().split('\n') 
subject_dict=dict() 
print('got 23andme subjects')

for line in subjects23andme: 
    subject_dict[line]=1 
import pandas as pd 
data=pd.read_csv("all.tsv",header=None,sep='\t')
outf=open('23andme.demographics.tsv','w')
for index,row in data.iterrows(): 
    subject=row[0] 
    if subject in subject_dict: 
        outf.write('\t'.join([str(i) for i in row])+'\n')
