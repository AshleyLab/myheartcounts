table_prefix=/scratch/groups/euan/projects/mhc/data/tables
#motion
#Version 1
#python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-motionTracker-v1.tsv $table_prefix/cardiovascular-motionActivityCollector-v1.tsv --outf v1.motion.hist --end_date 2015-10-28

#motion
#Version 2 (coaching) 
#python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-motionTracker-v1.tsv $table_prefix/cardiovascular-motionActivityCollector-v1.tsv --outf v2.motion.hist --start_date 2016-12-10

#HealthKit
#V1
#python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-HealthKitDataCollector-v1.tsv --outf v1.hk.hist --end_date 2015-10-28

#HealthKit
#V2
#python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-HealthKitDataCollector-v1.tsv --outf v2.hk.hist --start_date 2016-12-10

#6MWT
#V1
#python get_usage_histograms.py --source_tables $table_prefix/6-Minute\ Walk\ Test_SchemaV4-v2.tsv $table_prefix/cardiovascular-6MWT\ Displacement\ Data-v1.tsv $table_prefix/6-Minute\ Walk\ Test_SchemaV4-v6.tsv $table_prefix/cardiovascular-6-Minute\ Walk\ Test_SchemaV4-v1.tsv $table_prefix/cardiovascular-6MinuteWalkTest-v2.tsv --outf v1.6mwt.hist --end_date 2015-10-28

#6MWT
#V2
#python get_usage_histograms.py --source_tables $table_prefix/6-Minute\ Walk\ Test_SchemaV4-v2.tsv $table_prefix/cardiovascular-6MWT\ Displacement\ Data-v1.tsv $table_prefix/6-Minute\ Walk\ Test_SchemaV4-v6.tsv $table_prefix/cardiovascular-6-Minute\ Walk\ Test_SchemaV4-v1.tsv $table_prefix/cardiovascular-6MinuteWalkTest-v2.tsv --outf v2.6mwt.hist --start_date 2016-12-10

#SURVEY DATA, SPLIT BY TABLE, FOR DATASETS PAPER 

#ALL SURVEYS TOGETHER: 
python get_usage_histograms.py --source_tables \
    $table_prefix/cardiovascular-day_one-v1.tsv \
    $table_prefix/cardiovascular-par-q-quiz-v1.tsv \
    $table_prefix/cardiovascular-daily_check-v1.tsv \
    $table_prefix/cardiovascular-daily_check-v2.tsv \
    $table_prefix/cardiovascular-ActivitySleep-v1.tsv \
    $table_prefix/cardiovascular-risk_factors-v1.tsv \
    $table_prefix/cardiovascular-risk_factors_SchemaV2-v1.tsv \
    $table_prefix/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv \
    $table_prefix/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2.tsv \
    $table_prefix/cardiovascular-Diet_survey_cardio_SchemaV2-v1.tsv \
    $table_prefix/cardiovascular-Diet_survey_cardio-v1.tsv \
    $table_prefix/cardiovascular-satisfied-v1.tsv \
    $table_prefix/cardiovascular-satisfied_SchemaV2-v1.tsv \
    $table_prefix/cardiovascular-satisfied_SchemaV3-v1.tsv \
    --outf v1.surveys \
    --end_date 2015-10-28

#SURVEYS, INDIVIDUALLY: 
python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-day_one-v1.tsv \
    --outf v1.surveys.day1 \
    --end_date 2015-10-28

python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-par-q-quiz-v1.tsv \
    --outf v1.surveys.parq \
    --end_date 2015-10-28

python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-daily_check-v1.tsv $table_prefix/cardiovascular-daily_check-v2.tsv \
    --outf v1.surveys.dailycheck \
    --end_date 2015-10-28

python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-daily_check-v1.tsv $table_prefix/cardiovascular-daily_check-v2.tsv \
    --outf v1.surveys.dailycheck \
    --end_date 2015-10-28

python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-ActivitySleep-v1.tsv \
    --outf v1.surveys.activitysleep \
    --end_date 2015-10-28

python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-risk_factors-v1.tsv $table_prefix/cardiovascular-risk_factors_SchemaV2-v1.tsv \
    --outf v1.surveys.riskfactors \
    --end_date 2015-10-28

python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv $table_prefix/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2.tsv \
    --outf v1.surveys.heartage \
    --end_date 2015-10-28


python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-Diet_survey_cardio-v1.tsv $table_prefix/cardiovascular-Diet_survey_cardio_SchemaV2-v1.tsv \
    --outf v1.surveys.diet \
    --end_date 2015-10-28


python get_usage_histograms.py --source_tables $table_prefix/cardiovascular-satisfied-v1.tsv $table_prefix/cardiovascular-satisfied_SchemaV2-v1.tsv $table_prefix/cardiovascular-satisfied_SchemaV3-v1.tsv \
    --outf v1.surveys.life.satisfaction \
    --end_date 2015-10-28

