#!/bin/bash
#assemble motion tracker data 
python assemble_motion.py --source_tables /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-motionTracker-v1.tsv /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-motionActivityCollector-v1.tsv \
       --output_dir /scratch/PI/euan/projects/mhc/23andme/data_for_23andme/motion_tracker/motion_tracker \
       --blob_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
       --healthCode_indices 2 5 \
       --subjects /scratch/PI/euan/projects/mhc/data/tables/23andmesubjects.txt \
       --resume_from 0

#assemble health kit data DataCollector 
#python assemble_motion.py --source_tables /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitDataCollector-v1.tsv  \
#       --output_dir /scratch/PI/euan/projects/mhc/23andme/data_for_23andme/motion_tracker/health_kit/DataCollector \
#       --blob_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
#       --healthCode_indices 5 \
#       --subjects /scratch/PI/euan/projects/mhc/data/tables/23andmesubjects.txt \
#       --resume_from 0
#
#
#
##assemble health kit data WorkoutCollector 
#python assemble_motion.py --source_tables /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitDataCollector-v1.tsv  \
#       --output_dir /scratch/PI/euan/projects/mhc/23andme/data_for_23andme/motion_tracker/health_kit/WorkoutCollector \
#       --blob_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
#       --healthCode_indices 5 \
#       --subjects /scratch/PI/euan/projects/mhc/data/tables/23andmesubjects.txt \
#       --resume_from 0
#
#
#
##assemble health kit data SleepCollector 
#python assemble_motion.py --source_tables /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitSleepCollector-v1.tsv  \
#       --output_dir /scratch/PI/euan/projects/mhc/23andme/data_for_23andme/motion_tracker/health_kit/DataCollector \
#       --blob_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
#       --healthCode_indices 5 \
#       --subjects /scratch/PI/euan/projects/mhc/data/tables/23andmesubjects.txt \
#       --resume_from 0

