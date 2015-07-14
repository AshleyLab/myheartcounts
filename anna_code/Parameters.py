#BASE DIR FOR THE PROJECT - VARIES ON SCG3, MASAMUNE, LOCAL MACHINE 
basedir="/srv/gsfs0/projects/ashley/common/myheart/"
#GROUPED TIME SERIES DIRECTORIES! 
walktables=basedir+"grouped_timeseries/6minwalktables/"
cardio_disp_tables=basedir+"grouped_timeseries/cardiovascular_displacement/" 
healthkit_tables=basedir+"grouped_timeseries/health_kit/" 
motiontracker_table=basedir+"grouped_timeseries/motiontracker/"

#LIST OF ALL SUBJECTS IN STUDY 
subject_file=basedir+"results/subjects.txt" 


table_dir=basedir+"data/tables/" 
table_dir_sorted="/home/annashch/sorted_tables/"
synapse_dir=basedir+"data/synapseCache/"
outputf_name="/home/annashch/data_summary.tsv"
demographics=["cardiovascular-NonIdentifiableDemographicsTask-v2.tsv","cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv"]#,"cardiovascular-par-q quiz-v1.tsv"]
exclude_list=['6minWalk_healthCode_steps.tsv','cardio-cardio_activitysleep_survey-metadata.tsv','cardio-cardio_daily_check-metadata.tsv','cardio-cardio_diet_survey-metadata.tsv','cardio-cardio_CVhealth_survey-metadata.tsv','cardio-cardio_day_one-metadata.tsv','cardio-cardio_wellbeing_survey-metadata.tsv','cardiovascular-displacement-v1.tsv','cardiovascular-6MinuteWalkTest-v2_withSteps_filtered.tsv','cardiovascular-6MinuteWalkTest-v2_withSteps.tsv','cardiovascular-appVersion.tsv','cardiovascular-day_one-v1.tsv','cardiovascular-HealthKitSleepCollector-v1.tsv','cardiovascular-HealthKitSleepCollector-v1.tsv','cardiovascular-ios-survey-v1.tsv','cardiovascular-NonIdentifiableDemographics-v1.tsv','cardiovascular-NonIdentifiableDemographics-v2.tsv','cardiovascular-HealthKitWorkoutCollector-v1.tsv']
blob_files=['cardiovascular-6MinuteWalkTest-v2.tsv','cardiovascular-6MWT Displacement Data-v1.tsv','cardiovascular-HealthKitDataCollector-v1.tsv','cardiovascular-motionTracker-v1.tsv']
csv_formats=['cardiovascular-ActivitySleep-v1.tsv','cardiovascular-daily_check-v1.tsv','cardiovascular-Diet_survey_cardio-v1.tsv','cardiovascular-par-q quiz-v1.tsv','cardiovascular-risk_factors-v1.tsv','cardiovascular-satisfied-v1.tsv']  

blob_json_formats=['cardiovascular-6MinuteWalkTest-v2.tsv','cardiovascular-6MWT Displacement Data-v1.tsv']
blob_csv_formats=['cardiovascular-HealthKitDataCollector-v1.tsv','cardiovascular-motionTracker-v1.tsv','cardiovascular-displacement-v1.tsv'] 

#valid header files for blob objects 
blob_headers=dict() 
blob_headers['cardiovascular-displacement-v1.tsv']='startTime,endTime,type,value,unit,source,sourceIdentifier'
blob_headers['cardiovascular-motionTracker-v1.tsv']="dateAndTime,activityTypeName,activityTypeValue,confidenceName,confidenceRaw,confidencePercent"
blob_headers['cardiovascular-HealthKitDataCollector-v1.tsv']="datetime,type,value"

#missingf_name="/home/annashch/missing.tsv"
intermediate_results_dir="/home/annashch/intermediate_results/" 
#for analysis of cardiovascular displacement data
card_disp_table="/home/annashch/intermediate_results/disp.table" 
card_disp_results="/home/annashch/intermediate_results/card_disp_summary.tsv" 
bad_blobs=["2322845","2329292","2374912","2377807"] # THESE CONTAIN DATA IN NON-ASCII FORMAT 
