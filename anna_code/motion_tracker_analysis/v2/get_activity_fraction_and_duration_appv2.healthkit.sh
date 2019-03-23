#!/bin/sh
subject_set=$1
#DataCollector 
#python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitDataCollector-v1.tsv \
#    --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache/ \
#    --out_prefixes parsed_HealthKitData.$subject_set \
#    --data_types health_kit_data_collector \
#    --subjects /scratch/PI/euan/projects/mhc/data/tables/subjects/hk/x$subject_set \
#    --aws_file_pickle /scratch/PI/euan/projects/mhc/data/aws_interventions.p \
#    --ab_test /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv \
#    --appVersion /scratch/PI/euan/projects/mhc/data/tables/appVersionWithDates.tsv

#SleepCollector
python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitSleepCollector-v1.tsv \
    --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache/ \
    --out_prefixes HealthKitSleep \
    --data_types health_kit_sleep_collector \
    --subjects /scratch/PI/euan/projects/mhc/data/tables/subjects/hk.sleep \
    --aws_file_pickle /scratch/PI/euan/projects/mhc/data/aws_interventions.p \
    --ab_test /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv \
    --appVersion /scratch/PI/euan/projects/mhc/data/tables/appVersionWithDates.tsv


#Workout Collector 
#python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitWorkoutCollector-v1.tsv \
#    --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache/ \
#    --out_prefixes HealthKitWorkout \
#    --data_types health_kit_workout_collector \
#    --subjects /scratch/PI/euan/projects/mhc/data/tables/subjects/hk.workout \
#    --map_aws_to_healthcodes /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-AwsClientIdTask-v1.tsv \
#    --aws_file_pickle /scratch/PI/euan/projects/mhc/data/aws_interventions.p \
#    --ab_test /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv \
#    --appVersion /scratch/PI/euan/projects/mhc/data/tables/appVersionWithDates.tsv
    #--aws_files /scratch/PI/euan/projects/mhc/data/aws.all \
    


