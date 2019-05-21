#!/bin/bash

#full dataset
# remove SNPs with maf < 0.01 in population 
# remove SNPs not in Hardy Weinberg equilibrium 
# change chromosome naming convention: 23 -> X, 24 -> Y, 25 -> XY, 26 -> MT 
# generate vcf file without family id 

#remove any duplicate SNPs
plink --bfile ../23andmeBinary --list-duplicate-vars suppress-first ids-only
#change chrom names & filter to maf > 0.01 
plink --bfile ../23andmeBinary --output-chr M  --maf 0.01 --exclude plink.dupvar --make-bed  --out 23andmeBinary.nodupvar.maf01.chromnames
#exclude snps that have 0 genotyping rate 
plink --bfile 23andmeBinary.nodupvar.maf01.chromnames --exclude exclude.txt --make-bed --out 23andmeBinary.nodupvar.maf01.chromnames.remove0genotypes
#get the hardy weinberg annotation p-values 
plink --bfile 23andmeBinary.nodupvar.maf01.chromnames.remove0genotypes --hardy 
#remove SNPs out of hardy weinberg equilibrium 
plink --bfile 23andmeBinary.nodupvar.maf01.chromnames.remove0genotypes --hwe midp 1e-7 --make-bed --out 23andmeBinary.nodupvar.maf01.chromnames.remove0genotypes.hwe1e-7
#generate vcf file 
plink --bfile  23andmeBinary.nodupvar.maf01.chromnames.remove0genotypes.hwe1e-7  --recode vcf-iid --out 23andmeBinary
