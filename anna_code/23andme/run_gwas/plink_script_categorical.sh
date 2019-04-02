#!/bin/bash
mkdir results/$1 
plink --bfile /scratch/PI/euan/projects/mhc/code/anna_code/23andme/impute/imputed_bed/imputed.chr$2  --pheno categorical.phenotypes.casecontrol --pheno-name $1 --missing-phenotype -1000 --logistic --covar covariates.txt --out results/$1/$1.$2 --allow-no-sex
