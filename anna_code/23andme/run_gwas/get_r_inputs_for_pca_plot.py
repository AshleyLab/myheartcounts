#combine the self-reported ethnicity values and the PC's from GWAS into a single data frame for R 
ethnicity=open('ethnicity.tsv','r').read().strip().split('\n') 
pcs=open("pca_5pcs.eigenvec",'r').read().strip().split('\n') 
subject_dict=dict() 

for line in pcs: 
    tokens=line.split() 
    subject=tokens[0] 
    pcvals=tokens[1::] 
    subject_dict[subject]=pcvals 
    subject_dict[subject].append('Unknown')

for line in ethnicity: 
    tokens=line.split('\t') 
    subject=tokens[0] 
    ethnicity=tokens[1] 
    if subject in subject_dict: 
        subject_dict[subject][-1]=ethnicity
outf=open('pca_inputs.txt','w') 
outf.write('Subject\tFamily\tPC1\tPC2\tPC3\tPC4\tPC5\tEthnicity\n') 
for subject in subject_dict: 
    outf.write(subject+'\t'+'\t'.join(subject_dict[subject])+'\n')

    

