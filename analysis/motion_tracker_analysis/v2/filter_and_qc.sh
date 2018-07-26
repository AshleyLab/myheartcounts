#motion tracker data 
python filter_and_qc.py --data /scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/motion_tracker_combined.txt\
       --filters min_datapoints \
       --outf_filtered /scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/motion_tracker_combined.filtered.txt 

#health kit data 
python filter_and_qc.py --data /scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/health_kit_combined.txt \
    --filters extract_field extract_source \
    --source_to_extract apple.health \
    --outf_filtered /scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/healthkit_combined.stepcount.txt \
    --field_to_extract HKQuantityTypeIdentifierStepCount

python filter_and_qc.py --data /scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/health_kit_combined.txt \
    --filters extract_field extract_source \
    --outf_filtered /scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/healthkit_combined.distance.txt \
    --source_to_extract apple.health \
    --field_to_extract HKQuantityTypeIdentifierDistanceWalk
