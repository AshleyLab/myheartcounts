#!/bin/bash
#java -jar conform-gt.24May16.cee.jar ref=chr2.1kg.phase3.v5a.vcf.gz gt=23andme.chr2.subset.vcf.vcf out=mod.chr2 chrom=2 strict=false match=POS
ref_prefix=/oak/stanford/groups/euan/projects/annotations/homo_sapien/GRCH37/imputation_GRCh37
java -Xmx30g -jar /share/PI/euan/apps/beagle/conform-gt.24May16.cee.jar ref=$ref_prefix/bochet.gcc.biostat.washington.edu/beagle/1000_Genomes_phase3_v5a/b37.vcf/chr$1.1kg.phase3.v5a.vcf.gz gt=23andmeBinary.recoded.nodup.vcf.gz out=mod.chr$1 chrom=$1
