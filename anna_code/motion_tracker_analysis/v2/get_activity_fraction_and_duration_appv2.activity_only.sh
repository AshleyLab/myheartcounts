#!/bin/sh
subject_set=$1
python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-motionActivityCollector-v1.tsv\
       --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache_v2/\
       --out_prefixes parsed_v2_motionActivity.$subject_set\
       --data_types motion_tracker\
       --subjects /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/subjects/motion/x$subject_set\
       --intervention_metadata /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-ABTestResults-v1.tsv
