#!/bin/bash 
cd /scratch/PI/euan/projects/mhc/code/anna_code/23andme/run_gwas/results/$1
head -n1 $1.1.*assoc.logistic > /scratch/PI/euan/projects/mhc/code/anna_code/23andme/run_gwas/results_filtered/$1.assoc.logistic 
cat *assoc.logistic | grep -v "NA" | grep "ADD" | grep -v "CHR" >> /scratch/PI/euan/projects/mhc/code/anna_code/23andme/run_gwas/results_filtered/$1.assoc.logistic 
