#!/bin/bash
table_dir=/scratch/PI/euan/projects/mhc/data/tables
python use_days_by_conditions.py --app_version_table $table_dir/appVersionWithDates.tsv \
    --cardiovascular_risk_tables $table_dir/cardiovascular-risk_factors-v1.tsv $table_dir/cardiovascular-risk_factors_SchemaV2-v1.tsv \
    --life_satisfaction_tables $table_dir/cardiovascular-satisfied_SchemaV2-v1.tsv  $table_dir/cardiovascular-satisfied_SchemaV3-v1.tsv  $table_dir/cardiovascular-satisfied-v1.tsv \
    --outf use_days_by_condition.txt


