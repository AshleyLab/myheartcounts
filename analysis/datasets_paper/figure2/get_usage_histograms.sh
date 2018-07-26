table_prefix=/scratch/groups/euan/projects/mhc/data/tables
#motion
#Version 1
#python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-motionTracker-v1.tsv $table_prefix/cardiovascular-motionActivityCollector-v1.tsv --outf v1.motion.hist --end_date 2015-10-28

#motion
#Version 2 (coaching) 
#python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-motionTracker-v1.tsv $table_prefix/cardiovascular-motionActivityCollector-v1.tsv --outf v2.motion.hist --start_date 2016-12-10

#HealthKit
#V1
python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-HealthKitDataCollector-v1.tsv --outf v1.hk.hist --end_date 2015-10-28

#HealthKit
#V2
python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-HealthKitDataCollector-v1.tsv --outf v2.hk.hist --start_date 2016-12-10

#6MWT
#V1
python get_usage_histograms.py --source_tables $table_prefix/6-Minute\ Walk\ Test_SchemaV4-v2.tsv $table_prefix/cardiovascular-6MWT\ Displacement\ Data-v1.tsv $table_prefix/6-Minute\ Walk\ Test_SchemaV4-v6.tsv $table_prefix/cardiovascular-6-Minute\ Walk\ Test_SchemaV4-v1.tsv $table_prefix/cardiovascular-6MinuteWalkTest-v2.tsv --outf v1.6mwt.hist --end_date 2015-10-28

#6MWT
#V2
python get_usage_histograms.py --source_tables $table_prefix/6-Minute\ Walk\ Test_SchemaV4-v2.tsv $table_prefix/cardiovascular-6MWT\ Displacement\ Data-v1.tsv $table_prefix/6-Minute\ Walk\ Test_SchemaV4-v6.tsv $table_prefix/cardiovascular-6-Minute\ Walk\ Test_SchemaV4-v1.tsv $table_prefix/cardiovascular-6MinuteWalkTest-v2.tsv --outf v2.6mwt.hist --start_date 2016-12-10

