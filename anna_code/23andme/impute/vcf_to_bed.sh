#convert the imputed 23&Me data to bed file format 
for chrom in `seq 1 22` X 
do 
    plink --vcf imputed_vcf/imputed.chr$chrom.vcf.gz --make-bed --out imputed_bed/imputed.chr$chrom
done 
