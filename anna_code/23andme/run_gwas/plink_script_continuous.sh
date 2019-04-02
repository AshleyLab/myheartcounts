#!/bin/sh 
mkdir results/$1
#called 
#plink2 --bfile ../23andmeBinary --pheno continuous.phenotypes.formatted.csv --input-missing-phenotype -1000 --out results/$1/$1 --pheno-name $1 --glm
plink2 --bfile /scratch/PI/euan/projects/mhc/code/anna_code/23andme/impute/imputed_bed/imputed.chr$2 --pheno continuous.phenotypes.formatted.csv --input-missing-phenotype -1000 --out results/$1/$1.$2 --pheno-name $1 --glm
