#!/bin/bash
grep -R -w -f x$1 /oak/stanford/groups/euan/projects/ukbb/gwas/physical_activity_plink/v2/results_imputed/ >  ukbb.hits.$1.txt
