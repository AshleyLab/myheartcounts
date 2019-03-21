#!/bin/bash
ref_prefix=/oak/stanford/groups/euan/projects/annotations/homo_sapien/GRCH37/imputation_GRCh37
java -Xmx50g -jar /share/PI/euan/apps/beagle/beagle.28Sep18.793.jar gt=mod.chr$1.vcf.gz ref=$ref_prefix/bochet.gcc.biostat.washington.edu/beagle/1000_Genomes_phase3_v5a/b37.vcf/chr$1.1kg.phase3.v5a.vcf.gz map=/oak/stanford/groups/euan/projects/annotations/homo_sapien/GRCH37/imputation_GRCh37/plink_maps/plink.chr$1.GRCh37.map out=imputed.chr$1 chrom=$1 nthreads=20 excludemarkers=excludemarkers.txt

