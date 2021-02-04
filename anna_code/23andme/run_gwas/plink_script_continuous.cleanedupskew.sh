#!/bin/sh 
mkdir results/$1
#plink2 --bfile /scratch/PI/euan/projects/mhc/code/anna_code/23andme/impute/imputed_bed/imputed.chr$2 --pheno continuous.phenotypes.formatted.cleanedupskew.csv --input-missing-phenotype -1000 --out results/$1/$1.$2 --pheno-name $1 --glm
plink2 --bfile /scratch/PI/euan/projects/mhc/code/anna_code/23andme/impute/imputed_bed/imputed.chr$2 --pheno continuous.phenotypes.formatted.cleanedupskew2.csv --input-missing-phenotype -1000 --out results/$1/$1.$2 --pheno-name $1 --glm
