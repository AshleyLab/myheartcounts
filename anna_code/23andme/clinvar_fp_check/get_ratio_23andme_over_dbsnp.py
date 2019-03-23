import pandas as pd 
import pdb
#get panel coordinates
coordinates=pd.read_csv("23andmeBinary.map",header=None,sep=' ',dtype="str",engine="c")
print("loaded coordinates") 
snp_to_pos=dict()
for index,row in coordinates.iterrows():
    chrom=row[0]
    snp=row[1]
    pos=row[3]
    snp_to_pos[snp]=(chrom,pos)
print("got snp_to_pos mapping")

#create dictionary of SNPs from 23&Me
plink=pd.read_csv("plink.frqx",header=0,sep='\t', engine='c',dtype='str')
snp_dict=dict()
for index,row in plink.iterrows():
    snpid=row[1]
    #get chromsome & pos
    chrom_pos=snp_to_pos[snpid]
    chrom=str(chrom_pos[0])
    pos=chrom_pos[1] 
    a1=row[2]
    a2=row[3]
    a1_count=float(row[4])**2+float(row[5])
    a2_count=float(row[6])**2+float(row[5])
    total=a1_count+a2_count
    if total==0:
        continue 
    a1_freq=a1_count/total
    a2_freq=a2_count/total
    if chrom not in snp_dict:
        snp_dict[chrom]=dict()
    snp_dict[chrom][pos]=dict()
    snp_dict[chrom][pos][snpid]=dict()
    snp_dict[chrom][pos][snpid][a1]=a1_freq
    snp_dict[chrom][pos][snpid][a2]=a2_freq
print("made dictionary with 23&Me allele frequencies")
clinvar=pd.read_csv("clinvar.chrom.pos.txt",header=None,sep='\t',dtype="str",engine="c")
clinvar_dict=dict()
for index,row in clinvar.iterrows():
    chrom=str(row[0])
    pos=row[1]
    if chrom not in clinvar_dict:
        clinvar_dict[chrom]=dict()
    clinvar_dict[chrom][pos]=1
print("made clinvar dict")

outf=open("23andMe_freqs_MHC_over_dbSNP142.txt",'w')
outf.write('snpid\tchrom\tpos\tallele\tdbSNPfreq\tMHCfreq\tMHC/dbSNP\tMinorAllele\tInClinvar\n')
#chrom->pos->name->allele->freq
chroms=[str(i) for i in range(1,23)]+['X','Y'] 
for chrom in chroms:
    data=pd.read_csv("/mnt/lab_data/kundaje/annashch/chr"+str(chrom)+".snp142.txt",sep='\t',header=None,dtype="str",engine="c")
    print("checking chrom:"+str(chrom) +" in dbSNP 142")
    for index,row in data.iterrows():
        pos=row[3]
        if pos in snp_dict[chrom]:
            #get the ratio of allele frequencies
            cursnp=list(snp_dict[chrom][pos].keys())[0]
            dbSNPfreqs=str(row[24]).strip().split(',') 
            dbSNPalleles=str(row[22]).strip().split(',')
            for i in range(len(dbSNPalleles)):
                cur_allele=dbSNPalleles[i]
                if cur_allele not in snp_dict[chrom][pos][cursnp]:
                    continue 
                dbSNPfreq=float(dbSNPfreqs[i])
                if dbSNPfreq < 0.5:
                    minor_allele="1"
                else:
                    minor_allele="0"
                if pos in clinvar_dict[chrom]:
                    inclinvar="1"
                else:
                    inclinvar="0" 
                mhcfreq=float(snp_dict[chrom][pos][cursnp][cur_allele])
                try:
                    ratio = mhcfreq/dbSNPfreq
                except:
                    if mhcfreq==0:
                        ratio=1
                    else: 
                        ratio = mhcfreq 
                outf.write(cursnp+'\t'+chrom+'\t'+pos+'\t'+str(cur_allele)+'\t'+str(dbSNPfreq)+'\t'+str(mhcfreq)+'\t'+str(ratio)+'\t'+minor_allele+'\t'+inclinvar+'\n')
