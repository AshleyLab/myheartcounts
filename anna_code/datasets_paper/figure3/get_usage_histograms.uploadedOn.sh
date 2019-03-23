table_prefix=/scratch/groups/euan/projects/mhc/data/tables

#motion
#Version 1
#python get_usage_histograms.uploadedOn.py --source_tables $table_prefix/cardiovascular-motionTracker-v1.tsv $table_prefix/cardiovascular-motionActivityCollector-v1.tsv --outf v1.motion.hist.uploadedOn --end_date 2015-10-28

#HealthKit
#V1
#python get_usage_histograms.uploadedOn.py --source_tables $table_prefix/cardiovascular-HealthKitDataCollector-v1.tsv --outf v1.hk.hist.uploadedOn --end_date 2015-10-28


#6MWT
#V1
#python get_usage_histograms.uploadedOn.py --source_tables $table_prefix/6-Minute\ Walk\ Test_SchemaV4-v2.tsv $table_prefix/cardiovascular-6MWT\ Displacement\ Data-v1.tsv $table_prefix/6-Minute\ Walk\ Test_SchemaV4-v6.tsv $table_prefix/cardiovascular-6-Minute\ Walk\ Test_SchemaV4-v1.tsv $table_prefix/cardiovascular-6MinuteWalkTest-v2.tsv --outf v1.6mwt.hist.uploadedOn --end_date 2015-10-28


#ALL SURVEYS TOGETHER: 
python get_usage_histograms.uploadedOn.py --source_tables \
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
    --outf v1.surveys.uploadedOn \
    --end_date 2015-10-28

#SURVEYS, INDIVIDUALLY: 
python get_usage_histograms.uploadedOn.py --source_tables $table_prefix/cardiovascular-day_one-v1.tsv \
    --outf v1.surveys.day1.uploadedOn \
    --end_date 2015-10-28

python get_usage_histograms.uploadedOn.py --source_tables $table_prefix/cardiovascular-par-q-quiz-v1.tsv \
    --outf v1.surveys.parq.uploadedOn \
    --end_date 2015-10-28

python get_usage_histograms.uploadedOn.py --source_tables $table_prefix/cardiovascular-daily_check-v1.tsv $table_prefix/cardiovascular-daily_check-v2.tsv \
    --outf v1.surveys.dailycheck.uploadedOn \
    --end_date 2015-10-28

python get_usage_histograms.uploadedOn.py --source_tables $table_prefix/cardiovascular-daily_check-v1.tsv $table_prefix/cardiovascular-daily_check-v2.tsv \
    --outf v1.surveys.dailycheck.uploadedOn \
    --end_date 2015-10-28

python get_usage_histograms.uploadedOn.py --source_tables $table_prefix/cardiovascular-ActivitySleep-v1.tsv \
    --outf v1.surveys.activitysleep.uploadedOn \
    --end_date 2015-10-28

python get_usage_histograms.uploadedOn.py --source_tables $table_prefix/cardiovascular-risk_factors-v1.tsv $table_prefix/cardiovascular-risk_factors_SchemaV2-v1.tsv \
    --outf v1.surveys.riskfactors.uploadedOn \
    --end_date 2015-10-28

python get_usage_histograms.uploadedOn.py --source_tables $table_prefix/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv $table_prefix/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2.tsv \
    --outf v1.surveys.heartage.uploadedOn \
    --end_date 2015-10-28


python get_usage_histograms.uploadedOn.py --source_tables $table_prefix/cardiovascular-Diet_survey_cardio-v1.tsv $table_prefix/cardiovascular-Diet_survey_cardio_SchemaV2-v1.tsv \
    --outf v1.surveys.diet.uploadedOn \
    --end_date 2015-10-28


python get_usage_histograms.uploadedOn.py --source_tables $table_prefix/cardiovascular-satisfied-v1.tsv $table_prefix/cardiovascular-satisfied_SchemaV2-v1.tsv $table_prefix/cardiovascular-satisfied_SchemaV3-v1.tsv \
    --outf v1.surveys.life.satisfaction.uploadedOn \
    --end_date 2015-10-28


