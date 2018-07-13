#!/bin/sh
subject_set=$1
#DataCollector 
python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-HealthKitDataCollector-v1.tsv \
    --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache/ \
    --out_prefixes parsed_v2_HealthKitData.$subject_set \
    --data_types health_kit_data_collector \
    --subjects /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/subjects/healthkit_data/x$subject_set \
    #--map_aws_to_healthcodes /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-AwsClientIdTask-v1.tsv \
    --aws_file_pickle /scratch/PI/euan/projects/mhc/data/aws_interventions.p
    #--aws_files /scratch/PI/euan/projects/mhc/data/aws.all \
    --intervention_metadata /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv \
    --appVersion /scratch/PI/euan/projects/mhc/data/tables/appVersionWithDates.tsv

#Workout Collector 
#python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-HealthKitWorkoutCollector-v1.tsv \
#    --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache/ \
#    --out_prefixes parsed_v2_HealthKitWorkout.$subject_set \
#    --data_types health_kit_data_collector_aws \
#    --subjects /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/subjects/healthkit_workout/x$subject_set \
#    --map_aws_to_healthcodes /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-AwsClientIdTask-v1.tsv \
#    --aws_file_pickle /scratch/PI/euan/projects/mhc/data/aws_interventions.p
    #--aws_files /scratch/PI/euan/projects/mhc/data/aws.all \
    #--intervention_metadata /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv


#python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-HealthKitSleepCollector-v1.tsv \
#    --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache/ \
#    --out_prefixes parsed_v2_HealthKitSleep.$subject_set \
#    --data_types health_kit_sleep_collector_aws \
#    --subjects /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/subjects/healthkit_sleep/x$subject_set \
#    --map_aws_to_healthcodes /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-AwsClientIdTask-v1.tsv \
#    --aws_file_pickle /scratch/PI/euan/projects/mhc/data/aws_interventions.p
#    --aws_files /scratch/PI/euan/projects/mhc/data/aws.all \
#    --intervention_metadata /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv
