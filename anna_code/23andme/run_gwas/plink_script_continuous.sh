#!/bin/sh 
mkdir results/$1
plink2 --bfile ../23andmeBinary --pheno continuous.phenotypes.formatted.csv --input-missing-phenotype -1000 --out results/$1/$1 --pheno-name $1 --glm
