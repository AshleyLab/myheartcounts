#!/bin/bash
#copy the files to common location 
python assemble_6mwt.py --source_tables \
    /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-6-Minute\ Walk\ Test_SchemaV4-v1.tsv \
    /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-6MinuteWalkTest-v2.tsv \
    /scratch/PI/euan/projects/mhc/data/tables/6-Minute\ Walk\ Test_SchemaV4-v2.tsv  \
    /scratch/PI/euan/projects/mhc/data/tables/6-Minute\ Walk\ Test_SchemaV4-v6.tsv \
    --task copy_sources \
    --output_dir /scratch/PI/euan/projects/mhc/data/6mwt_tmp \
    --blob_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
    --healthCode_indices 5 2 5 5 \
    --resume_from 0




#aggregate by subject
#python assemble_6mwt.py --task group_by_subject \
#       --pedometer_walk_dir /scratch/PI/euan/projects/mhc/data/6mwt_tmp/pedometer_walk_dir \
#       --accel_walk_dir /scratch/PI/euan/projects/mhc/data/6mwt_tmp/accel_walk_dir \
#       --device_motion_walk_dir /scratch/PI/euan/projects/mhc/data/6mwt_tmp/device_motion_walk_dir \
#       --heart_rate_walk_dir /scratch/PI/euan/projects/mhc/data/6mwt_tmp/heart_rate_walk_dir \
#       --accel_rest_dir /scratch/PI/euan/projects/mhc/data/6mwt_tmp/accel_rest_dir \
#       --device_motion_rest_dir /scratch/PI/euan/projects/mhc/data/6mwt_tmp/device_motion_rest_dir \
#       --heart_rate_rest_dir /scratch/PI/euan/projects/mhc/data/6mwt_tmp/heart_rate_rest_dir \
#       --output_dir /scratch/PI/euan/projects/mhc/data/6mwt_tmp \
#       --subject_index $1

