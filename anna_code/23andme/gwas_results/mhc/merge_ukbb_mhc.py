import pandas as pd 
import pdb 
ukbb_val=pd.read_table("results.significant.txt")
mhc_cont=pd.read_table("mhc.continuous.results",header=0,sep='\t',dtype=object)
mhc_cat=pd.read_table("mhc.categorical.results",header=0,sep='\t',dtype=object)
ukbb_dict=dict() 
mhc_dict=dict() 
for index,row in ukbb_val.iterrows(): 
    snp=row[0]
    pval=row[1] 
    phenotype=row[2] 
    if pval<5e-6: 
        if snp not in ukbb_dict: 
            ukbb_dict[snp]=[str(phenotype)] 
        else: 
            ukbb_dict[snp].append(str(phenotype)) 
print("made ukbb dict") 
pdb.set_trace() 
for index,row in mhc_cont.iterrows(): 
    snp=row[0] 
    phenotype=row[-1] 
    print(phenotype) 
    if snp not in mhc_dict: 
        mhc_dict[snp]=[str(phenotype)]
    else: 
        mhc_dict[snp].append(str(phenotype)) 
print("made mhc continuous dictionary") 
pdb.set_trace() 
for index,row in mhc_cat.iterrows(): 
    snp=row[0] 
    phenotype=row[-3] 
    print(phenotype) 
    if snp not in mhc_dict: 
        mhc_dict[snp]=[str(phenotype)] 
    else: 
        mhc_dict[snp].append(str(phenotype)) 
print("made mhc categorical dictionary") 
pdb.set_trace() 
outf=open("merged.txt",'w') 
for snp in ukbb_dict: 
    outf.write(snp+'\t'+','.join(ukbb_dict[snp])+'\t'+','.join(mhc_dict[snp])+'\n')

