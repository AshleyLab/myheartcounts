#!/bin/sh
subject_set=$1
#motionActivity
python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-motionActivityCollector-v1.tsv \
    --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache/ \
    --out_prefixes parsed_motionActivity.$subject_set \
    --data_types motion_tracker \
    --subjects /scratch/PI/euan/projects/mhc/data/tables/subjects/motion.activity/x$subject_set \
    --aws_file_pickle /scratch/PI/euan/projects/mhc/data/aws_interventions.p \
    --ab_test /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv \
    --appVersion /scratch/PI/euan/projects/mhc/data/tables/appVersionWithDates.tsv


#motionTracker
python get_activity_fraction_and_duration_appv2.py --tables /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-motionTracker-v1.tsv \
    --synapseCacheDir /scratch/PI/euan/projects/mhc/data/synapseCache/ \
    --out_prefixes parsed_motionTracker.$subject_set \
    --data_types motion_tracker \
    --subjects /scratch/PI/euan/projects/mhc/data/tables/subjects/motion.tracker/x$subject_set \
    --aws_file_pickle /scratch/PI/euan/projects/mhc/data/aws_interventions.p \
    --ab_test /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-ABTestResults-v1.tsv \
    --appVersion /scratch/PI/euan/projects/mhc/data/tables/appVersionWithDates.tsv

