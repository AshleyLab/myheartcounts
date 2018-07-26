#SANITIZE THE 3 HEALTHKIT DATA TABLES 
python sanitize_hk_data.py --source_table /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitDataCollector-v1.tsv /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitWorkoutCollector-v1.tsv /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-HealthKitSleepCollector-v1.tsv

#SMALL EXAMPLE
#python sanitize_hk_data.py --source_table test.tsv

