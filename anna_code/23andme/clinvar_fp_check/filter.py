import pandas as pd 
import pdb

#get panel coordinates
badSNPs=pd.read_csv("badSNPs.txt",header=0,sep='\t',dtype='str',engine='c')
dbSNP=pd.read_csv("snp142.suspect.txt",header=None,sep='\t',dtype='str',engine='c')
outf=open("badSNPs.cleaned.txt",'w')
badSNP_dict=dict()
for index,row in badSNPs.iterrows():
    chrom=row['chrom']
    pos=row['pos']
    snpid=row['snpid']
    allele=row['allele']
    mhcfreq=row['MHCfreq'] 
    if chrom not in badSNP_dict:
        badSNP_dict[chrom]=dict()
    if pos not in badSNP_dict[chrom]:
        badSNP_dict[chrom][pos]=dict()
        badSNP_dict[chrom][pos]['snpid']=snpid
        badSNP_dict[chrom][pos]['InClinvar']=row['InClinvar']
    if 'alleles' not in badSNP_dict[chrom][pos]:
        badSNP_dict[chrom][pos]['alleles']=dict()
    badSNP_dict[chrom][pos]['alleles'][allele]=mhcfreq
print("made bad snp dictionary")
for index,row in dbSNP.iterrows():
    chrom=row[1].replace('chr','')
    pos=row[3]
    if chrom in badSNP_dict:
        if pos in badSNP_dict[chrom]:
            ancestral=row[7]
            try:
                dbSNPfreqs=[float(i) for i in str(row[24]).strip(',').split(',')]
            except:
                pdb.set_trace()
            dbSNPalleles=str(row[22]).strip(',').split(',')
            #treat the ancestral allele as major allele
            snpid=badSNP_dict[chrom][pos]['snpid']
            for allele in dbSNPalleles:
                if allele==ancestral:
                    minor="0"
                    dbSNPfreq=max(dbSNPfreqs)
                else:
                    minor='1'
                    dbSNPfreq=min(dbSNPfreqs)
                try:
                    mhcfreq=badSNP_dict[chrom][pos]['alleles'][allele]
                except:
                    mhcfreq=str(0)
                ratio=float(mhcfreq)/float(dbSNPfreq)
                inclinvar=badSNP_dict[chrom][pos]['InClinvar']
                outf.write(snpid+'\t'+chrom+'\t'+pos+'\t'+allele+'\t'+str(dbSNPfreq)+'\t'+mhcfreq+'\t'+str(ratio)+'\t'+minor+'\t'+inclinvar+'\n')
    
