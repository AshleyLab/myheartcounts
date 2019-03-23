#!/bin/bash
plink --bfile /oak/stanford/groups/euan/projects/ukbb/data/genetic_data/v2/plink_small/ukb_imp_chr$1\_v2 --r2 --ld-snp-list merged.$1 --ld-window-r2 0.8 --out $1.linkage
