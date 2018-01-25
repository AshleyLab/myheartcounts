#motion tracker data 
python filter_and_qc.py --data /scratch/PI/euan/projects/mhc/data/timeseries_v2/motion_tracker_combined.txt\
       --filters min_datapoints account_for_huge_gaps_in_time\
       --qc_metrics days_in_study_reported_observed missing_intervention_assignment\
       --outf_filtered /scratch/PI/euan/projects/mhc/data/timeseries_v2/motion_tracker_combined.filered.txt\
       --outf_qc_metrics /scratch/PI/euan/projects/mhc/data/timeseries_v2/days_in_study_reported_vs_observed.motion /scratch/PI/euan/projects/mhc/data/timeseries_v2/missing_intervention.motion\
       --intervention_metadata /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-ABTestResults-v1.tsv

#health kit data 
python filter_and_qc.py --data /scratch/PI/euan/projects/mhc/data/timeseries_v2/health_kit_combined.txt\
       --filters extract_field\
       --qc_metrics days_in_study_reported_observed missing_intervention_assignment\
       --outf_filtered /scratch/PI/euan/projects/mhc/data/timeseries_v2/healthkit_combined.stepcount.txt\
       --outf_qc_metrics /scratch/PI/euan/projects/mhc/data/timeseries_v2/days_in_study_reported_vs_observed.healthkit /scratch/PI/euan/projects/mhc/data/timeseries_v2/missing_intervention.healthkit\
       --intervention_metadata /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-ABTestResults-v1.tsv\
       --field_to_extract HKQuantityTypeIdentifierStepCount

python filter_and_qc.py --data /scratch/PI/euan/projects/mhc/data/timeseries_v2/health_kit_combined.txt\
       --filters extract_field\
       --outf_filtered /scratch/PI/euan/projects/mhc/data/timeseries_v2/healthkit_combined.distance.txt\
       --intervention_metadata /scratch/PI/euan/projects/mhc/data/tables/v2_data_subset/cardiovascular-ABTestResults-v1.tsv\
       --field_to_extract HKQuantityTypeIdentifierDistanceWalk
