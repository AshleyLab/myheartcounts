#!/bin/bash

# repeat filter steps on the imputed panel:
# remove any duplicate SNPs
# remove SNPs with maf < 0.01 in population 
# remove SNPs not in Hardy Weinberg equilibrium 

#Remove SNPs with DR2 score < 0.8 (this is same as INFO score calculated by PLINK --proxy-assoc command, but that command is deprecated) 
python remove_low_dr2_from_imputed_snps.py --input_vcf imputed_vcf/imputed.chr$1.vcf.gz --outf dr2.below0.8.$1 
#Identify duplicate SNPs
plink --bfile imputed_bed/imputed.chr$1 --list-duplicate-vars suppress-first ids-only --out plink.dupvar.imputed.$1
#Cat the low DR2 and duplicate SNPs to generate SNP list to exclude 
cat dr2.below0.8.$1 plink.dupvar.imputed.$1 | sort |uniq > imputed.exclude.$1
#filter to maf > 0.01 , minor allele count >10, genotyping rate >=10% , hwe<1e-7 
plink --bfile imputed_bed/imputed.chr$1 --output-chr M --hwe midp 1e-7 --maf 0.01 --mac 10 --geno 0.9 --exclude imputed.exclude.$1 --make-bed  --out imputed.$1.cleaned 





