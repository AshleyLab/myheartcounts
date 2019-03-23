#!/bin/bash 
plink --bfile imputed_bed/imputed.chr1 --merge-list chromfiles.txt --make-bed --out 23andmeBinary.imputed
