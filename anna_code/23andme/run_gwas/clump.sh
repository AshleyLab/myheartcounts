#!/bin/bash 
plink --bfile /scratch/PI/euan/projects/mhc/code/anna_code/23andme/impute/23andmeBinary.imputed --clump results_filtered/$1 --out clumped/$1 --clump-snp-field ID
