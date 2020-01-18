#!/bin/sh
subject_set=$1
data_prefix=/oak/stanford/groups/euan/projects/mhc
#DataCollector 
#python get_activity_fraction_and_duration_appv2.py --tables $data_prefix/mhc/data/tables/cardiovascular-HealthKitDataCollector-v1.tsv \
#    --synapseCacheDir $data_prefix/mhc/data/synapseCache/ \
#    --out_prefixes parsed_HealthKitData.$subject_set \
#    --data_types health_kit_data_collector \
#    --subjects $data_prefix/mhc/data/tables/subjects/hk/x$subject_set \
#    --aws_file_pickle $data_prefix/mhc/data/aws_interventions.p \
#    --ab_test $data_prefix/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv \
#    --appVersion $data_prefix/mhc/data/tables/appVersionWithDates.tsv

#SleepCollector
python get_activity_fraction_and_duration_appv2.py --tables $data_prefix/data/tables/cardiovascular-HealthKitSleepCollector-v1.tsv \
    --synapseCacheDir $data_prefix/mhc/data/synapseCache/ \
    --out_prefixes HealthKitSleep \
    --data_types health_kit_sleep_collector \
    --subjects $data_prefix/mhc/data/tables/subjects/hk.sleep \
    --aws_file_pickle $data_prefix/mhc/data/aws_interventions.p \
    --ab_test $data_prefix/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv \
    --appVersion $data_prefix/mhc/data/tables/appVersionWithDates.tsv


#Workout Collector 
#python get_activity_fraction_and_duration_appv2.py --tables $data_prefix/mhc/data/tables/cardiovascular-HealthKitWorkoutCollector-v1.tsv \
#    --synapseCacheDir $data_prefix/mhc/data/synapseCache/ \
#    --out_prefixes HealthKitWorkout \
#    --data_types health_kit_workout_collector \
#    --subjects $data_prefix/mhc/data/tables/subjects/hk.workout \
#    --map_aws_to_healthcodes $data_prefix/mhc/data/tables/cardiovascular-AwsClientIdTask-v1.tsv \
#    --aws_file_pickle $data_prefix/mhc/data/aws_interventions.p \
#    --ab_test $data_prefix/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv \
#    --appVersion $data_prefix/mhc/data/tables/appVersionWithDates.tsv
    #--aws_files $data_prefix/mhc/data/aws.all \
    


