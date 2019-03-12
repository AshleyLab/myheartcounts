#!/bin/bash
plink --bfile ukb_imp_chr2.subset --bmerge ../23andmeBinary.bed  ../23andmeBinary.bim  ../23andmeBinary.fam  --make-bed --out merged.chr2
plink --bfile ukb_imp_chr3.subset --bmerge ../23andmeBinary.bed  ../23andmeBinary.bim  ../23andmeBinary.fam  --make-bed --out merged.chr3


