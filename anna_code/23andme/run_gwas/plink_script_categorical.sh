#!/bin/bash
mkdir results/$1 
plink --bfile ../23andmeBinary --pheno categorical.phenotypes.casecontrol --pheno-name $1 --missing-phenotype -1000 --logistic --covar covariates.txt --out results/$1/$1 --allow-no-sex
