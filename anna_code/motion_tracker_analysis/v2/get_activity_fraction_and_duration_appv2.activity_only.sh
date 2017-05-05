#!/bin/sh
#SBATCH --mem=8000
python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-motionActivityCollector-v1.tsv\
       --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache_v2/\
       --out_prefixes parsed_v2_motionActivity\
       --data_types motion_tracker\
       --intervention_metadata /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-ABTestResults-v1.tsv
