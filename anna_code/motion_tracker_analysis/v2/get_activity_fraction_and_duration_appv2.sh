#!/bin/sh

#run motion tracker & health kit analysis in a single command 
#python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-motionActivityCollector-v1.tsv /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-HealthKitDataCollector-v1.tsv\
#       --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache_v2/\
#       --out_prefixes parsed_v2_motionActivity parsed_v2_HealthKitData\
#       --data_types motion_tracker health_kit_data_collector\
#       --intervention_metadata /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-ABTestResults-v1.tsv

#run just the motion tracker analysis
#python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-motionActivityCollector-v1.tsv \
#       --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache_v2/\
#       --out_prefixes parsed_v2_motionActivity \
#       --data_types motion_tracker\
#       --intervention_metadata /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-ABTestResults-v1.tsv


#run just the health kit analysis
python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-HealthKitDataCollector-v1.tsv\
       --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache_v2/\
       --out_prefixes parsed_v2_HealthKitData\
       --data_types health_kit_data_collector\
       --intervention_metadata /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-ABTestResults-v1.tsv
