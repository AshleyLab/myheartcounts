#plink --bfile ukb_imp_chr2.subset --recode vcf --out ukb_imp_chr2.subset.vcf
#plink --bfile ukb_imp_chr3.subset --recode vcf --out ukb_imp_chr3.subset.vcf
#plink --bfile 23andme.chr2.subset --recode vcf --out 23andme.chr2.subset.vcf
#plink --bfile 23andme.chr3.subset --recode vcf --out 23andme.chr3.subset.vcf

#full dataset
# ignore positions with no Alt allele 
# change chromosome naming convention: 23 -> X, 24 -> Y, 25 -> XY, 26 -> MT 
# generate vcf file without family id 

#remove any duplicate SNPs
plink --bfile 23andmeBinary --list-duplicate-vars suppress-first ids-only
plink --bfile 23andmeBinary --mac 1 --output-chr M --exclude plink.dupvar --recode vcf-iid --out 23andmeBinary
