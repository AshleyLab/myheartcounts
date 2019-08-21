prefix=/oak/stanford/groups/euan/projects/mhc/data/tables
python time_lag.py --tables $prefix/cardiovascular-HealthKitDataCollector-v1.tsv $prefix/cardiovascular-motionActivityCollector-v1.tsv $prefix/6-Minute\ Walk\ Test_SchemaV4-v6.tsv $prefix/cardiovascular-daily_check-v2.tsv \
    --outf delayed.cardiovascular-HealthKitDataCollector-v1.tsv delayed.cardiovascular-motionActivityCollector-v1.tsv 6-Minute_Walk_Test_SchemaV4-v6.tsv cardiovascular-daily_check-v2.tsv

