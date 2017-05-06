#!/bin/sh
#SBATCH --time=10:00
python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-motionActivityCollector-v1.tsv\
       --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache_v2/\
       --out_prefixes parsed_v2_motionActivity\
       --data_types motion_tracker\
       --subjects subjects_for_test.txt\
       --intervention_metadata /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-ABTestResults-v1.tsv
