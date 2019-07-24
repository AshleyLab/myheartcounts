#!/bin/bash 
prefix=/scratch/PI/euan/projects/mhc/data/tables
cut -f5,8,16,17 $prefix/cardiovascular-HealthKitDataCollector-v1.tsv > subset.cardiovascular-HealthKitDataCollector-v1.tsv
