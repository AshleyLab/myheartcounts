#!/usr/bin/env bash
key="$1"

case $key in
    1)
    python find_blob_files_to_download.py --table /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitWorkoutCollector-v1.tsv  \
	--columns -1 \
	--blob_source_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
	--outf  missing_blobs_cardiovascular-HealthKitWorkoutCollector-v1.tsv
    ;;
    2)
    python find_blob_files_to_download.py --table /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-motionTracker-v1.tsv  \
	--columns -1 \
	--blob_source_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
	--outf  missing_blobs_cardiovascular-motionTracker-v1.tsv
    ;;
    3)
python find_blob_files_to_download.py --table /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-motionActivityCollector-v1.tsv  \
    --columns -1 \
    --blob_source_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
    --outf  missing_blobs_cardiovascular-motionActivityCollector-v1.tsv
    ;;
    4)
python find_blob_files_to_download.py --table /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitDataCollector-v1.tsv  \
    --columns -1 \
    --blob_source_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
    --outf  missing_blobs_cardiovascular-HealthKitDataCollector-v1.tsv
    ;;
    5)
python find_blob_files_to_download.py --table /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitSleepCollector-v1.tsv  \
    --columns -1 \
    --blob_source_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
    --outf  missing_blobs_cardiovascular-HealthKitSleepCollector-v1.tsv
    ;;
    6)
python find_blob_files_to_download.py --table /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-6-Minute\ Walk\ Test_SchemaV4-v1.tsv   \
    --columns -3 -4 -5 -6 -7 -8 -9 \
    --blob_source_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
    --outf  missing_blobs_cardiovascular-6-Minute_Walk_Test_SchemaV4-v1.tsv 
    ;;
    7)
python find_blob_files_to_download.py --table /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-6MinuteWalkTest-v2.tsv \
    --columns -1 -2 -3 -4 -5 -6 -7 \
    --blob_source_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
    --outf  missing_blobs_cardiovascular-6MinuteWalkTest-v2.tsv
    ;;
    8)
python find_blob_files_to_download.py --table /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-6MWT\ Displacement\ Data-v1.tsv  \
    --columns -1 \
    --blob_source_dir /scratch/PI/euan/projects/mhc/data/synapseCache \
    --outf  missing_blobscardiovascular-6MWT_Displacement_Data-v1.tsv
    ;;
esac
