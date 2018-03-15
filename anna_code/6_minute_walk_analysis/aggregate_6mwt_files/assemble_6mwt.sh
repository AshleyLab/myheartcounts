#!/bin/bash
#copy the files to common location 
#python assemble_6mwt.py --source_tables /scratch/PI/euan/projects/mhc/data/tables/6mwt/cardiovascular-6-MinuteWalkTest_SchemaV4-v1.tsv /scratch/PI/euan/projects/mhc/data/tables/6mwt/cardiovascular-6MinuteWalkTest-v2_withSteps.tsv /scratch/PI/euan/projects/mhc/data/tables/6mwt/cardiovascular-6MinuteWalkTest-v2_withSteps_filtered.tsv /scratch/PI/euan/projects/mhc/data/tables/6mwt/cardiovascular-6MinuteWalkTest-v2.tsv --task copy_sources --output_dir /scratch/PI/euan/projects/mhc/data/6mwt --blob_dir /scratch/PI/euan/projects/mhc/data/synapseCache --healthCode_indices 5 1 1 2 --resume_from 0

#aggregate by subject 
#python assemble_6mwt.py --source_tables /scratch/PI/euan/projects/mhc/data/tables/6mwt/cardiovascular-6-MinuteWalkTest_SchemaV4-v1.tsv /scratch/PI/euan/projects/mhc/data/tables/6mwt/cardiovascular-6MinuteWalkTest-v2_withSteps.tsv /scratch/PI/euan/projects/mhc/data/tables/6mwt/cardiovascular-6MinuteWalkTest-v2_withSteps_filtered.tsv /scratch/PI/euan/projects/mhc/data/tables/6mwt/cardiovascular-6MinuteWalkTest-v2.tsv --task copy_sources --output_dir /scratch/PI/euan/projects/mhc/data/6mwt --blob_dir /scratch/PI/euan/projects/mhc/data/synapseCache --healthCode_indices 5 1 1 2 --resume_from 0  

#aggregate by subject
python assemble_6mwt.py --task group_by_subject\
       --pedometer_walk_dir /scratch/PI/euan/projects/mhc/data/6mwt/pedometer_walk_dir\
       --accel_walk_dir /scratch/PI/euan/projects/mhc/data/6mwt/accel_walk_dir\
       --device_motion_walk_dir /scratch/PI/euan/projects/mhc/data/6mwt/device_motion_walk_dir\
       --heart_rate_walk_dir /scratch/PI/euan/projects/mhc/data/6mwt/heart_rate_walk_dir\
       --accel_rest_dir /scratch/PI/euan/projects/mhc/data/6mwt/accel_rest_dir\
       --device_motion_rest_dir /scratch/PI/euan/projects/mhc/data/6mwt/device_motion_rest_dir\
       --heart_rate_rest_dir /scratch/PI/euan/projects/mhc/data/6mwt/heart_rate_rest_dir\
       --output_dir /scratch/PI/euan/projects/mhc/data/6mwt\
       --subject_index $1

