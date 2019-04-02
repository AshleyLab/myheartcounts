#!/bin/bash 
cd /scratch/PI/euan/projects/mhc/code/anna_code/23andme/run_gwas/results/$1
head -n1 $1.1.*linear > /scratch/PI/euan/projects/mhc/code/anna_code/23andme/run_gwas/results_filtered/$1.linear 
cat *linear | grep -v "NA" | grep "ADD" | grep -v "CHR" >> /scratch/PI/euan/projects/mhc/code/anna_code/23andme/run_gwas/results_filtered/$1.linear 
