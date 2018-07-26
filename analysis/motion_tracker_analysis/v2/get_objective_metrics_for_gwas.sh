python get_objective_metrics_for_gwas.py --source_table_motion_tracker /scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/motion_tracker_combined.filered.txt\
       --source_table_health_kit /scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/health_kit_combined.txt\
       --metrics_motion_tracker kmeans_cluster percent_of_time_active\
       --metrics_health_kit mean_step_count mean_distance_walked\
       --outf /scratch/PI/euan/projects/mhc/data/timeseries_v2/summary/gwas_outcomes_motion_and_healthkit_observed.txt
