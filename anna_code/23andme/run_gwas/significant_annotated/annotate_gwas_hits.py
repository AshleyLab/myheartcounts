#annotate GWAS hits with allele frequency 
import pdb 
import argparse 
import pandas as pd 
import numpy as np 

def parse_args(): 
    parser=argparse.ArgumentParser(description="annotate GWAS hits with allele frequency ") 
    parser.add_argument("--GWAS_hits_continuous",default="../significant/gwas_hits_5e-6_imputed/all.linear") 
    parser.add_argument("--GWAS_hits_categorical",default="../significant/gwas_hits_5e-6_imputed/all.hybrid") 
    parser.add_argument("--GWAS_freqs",default="/scratch/PI/euan/projects/mhc/code/anna_code/23andme/impute/plink.frq.counts") 
    parser.add_argument("--categorical_pheno_file",default="../categorical.phenotypes.casecontrol") 
    parser.add_argument("--out_prefix",default="significant.5e-6.annotated")
    return parser.parse_args() 
    
def main():  
    args=parse_args() 
    freqs=pd.read_csv(args.GWAS_freqs,header=0,index_col=False, delim_whitespace=True)
    case_control_counts=pd.read_csv(args.categorical_pheno_file,header=0,index_col=False,sep='\t')
    hits_continuous=pd.read_csv(args.GWAS_hits_continuous,header=0,index_col=False,sep='\t')
    hits_categorical=pd.read_csv(args.GWAS_hits_categorical,header=0,index_col=False,sep='\t')
    print("loaded source tables")
    #annotate the allele frequencies 
    hits_continuous=hits_continuous.merge(freqs, left_on='SNP', right_on='SNP', how='left')
    hits_categorical=hits_categorical.merge(freqs,left_on="SNP",right_on="SNP",how='left') 
    #add the case/control counts to the categorical data 
    hits_categorical['case_counts']=np.zeros(hits_categorical.shape[0])
    hits_categorical['control_counts']=np.zeros(hits_categorical.shape[0])
    for index,row in hits_categorical.iterrows(): 
        cur_phenotype=row['FIELD']
        control_counts=sum(case_control_counts[cur_phenotype]==1)
        case_counts=sum(case_control_counts[cur_phenotype]==2)
        hits_categorical.loc[index,'control_counts']=control_counts
        hits_categorical.loc[index,'case_counts']=case_counts
    #write outputs
    hits_continuous.to_csv(args.out_prefix+".continuous",sep='\t',header=True,index=False)
    hits_categorical.to_csv(args.out_prefix+".categorical",sep='\t',header=True,index=False) 



if __name__=="__main__":
    main() 
