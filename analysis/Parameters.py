#BASE DIR FOR THE PROJECT - VARIES ON SCG3, MASAMUNE, LOCAL MACHINE 
basedir="/srv/gsfs0/projects/ashley/common/myheart/"
table_dir=basedir+"data/tables/" 
synapse_dir=basedir+"data/synapseCache/"

#EXTERNAL DATA 
external_data=basedir+"data/external/"
ssa_national=basedir+"data/external/national/"
ssa_national_outf=ssa_national+"ssa_national_summary.txt" 
ssa_state=basedir+"data/external/state/"
ssa_state_outf=ssa_state+"ssa_state_summary.txt" 

#####PARAMETERS FOR GROUPING TIME SERIES DATA############

walktables=basedir+"grouped_timeseries/6minute_walk/"
walk_file='cardiovascular-6MinuteWalkTest-v2.tsv'
walk_subsets='/home/annashch/myheartcounts/anna_code/data_cleanup_and_formatting/6minwalktables/'


cardio_disp_table=basedir+"grouped_timeseries/cardiovascular_displacement/"
cardio_disp_files=['cardiovascular-displacement-v1.tsv']
cardio_disp_subsets='/home/annashch/myheartcounts/anna_code/data_cleanup_and_formatting/carddisptables/'

healthkit_tables=basedir+"grouped_timeseries/health_kit/"
healthkit_files=['cardiovascular-HealthKitWorkoutCollector-v1.tsv','cardiovascular-HealthKitSleepCollector-v1.tsv','cardiovascular-HealthKitDataCollector-v1.tsv'] 
healthkit_subsets='/home/annashch/myheartcounts/anna_code/data_cleanup_and_formatting/healthkittables/'

motiontracker_tables=basedir+"grouped_timeseries/motiontracker/"
motiontracker_files=['cardiovascular-motionTracker-v1.tsv','cardiovascular-motionActivityCollector-v1.tsv']
motiontracker_subsets='/home/annashch/myheartcounts/anna_code/data_cleanup_and_formatting/motiontrackertables/'


#LIST OF ALL SUBJECTS IN STUDY 
subject_file=basedir+"/subjects.txt" 
#LIST OF ALL THE TABLES WE HAVE DOWNLOADED
table_master_list=basedir+"/tables.txt" 

#SUMMARY FILE OF DEMOGRAPHIC AND SURVEY INFORMATION 
survey_summary_file=basedir+"/results/NonTimeSeries.txt"
feature_presence_absence_file=basedir+"/results/feature_presence_absence.tsv" 

#UPLOADS OVER TIME 
uploads_file=basedir+"/results/uploads_by_date_and_version.tsv" 

#SUBJECTS JOINING OVER TIME 
new_subjects_file=basedir+"/results/new_subjects.tsv" 

demographics=["cardiovascular-NonIdentifiableDemographicsTask-v2.tsv.NODUPLICATES","cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv","cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2.tsv"]#,"cardiovascular-par-q quiz-v1.tsv"]


exclude_list=['6minWalk_healthCode_steps.tsv','cardio-cardio_activitysleep_survey-metadata.tsv','cardio-cardio_daily_check-metadata.tsv','cardio-cardio_diet_survey-metadata.tsv','cardio-cardio_CVhealth_survey-metadata.tsv','cardio-cardio_day_one-metadata.tsv','cardio-cardio_wellbeing_survey-metadata.tsv','cardiovascular-displacement-v1.tsv','cardiovascular-6MinuteWalkTest-v2_withSteps_filtered.tsv','cardiovascular-6MinuteWalkTest-v2_withSteps.tsv','cardiovascular-appVersion.tsv','cardiovascular-day_one-v1.tsv','cardiovascular-ios-survey-v1.tsv','cardiovascular-NonIdentifiableDemographics-v1.tsv','cardiovascular-NonIdentifiableDemographics-v2.tsv','cardiovascular-HealthKitWorkoutCollector-v1.tsv']

blob_files=['cardiovascular-6MinuteWalkTest-v2.tsv','cardiovascular-6MWT Displacement Data-v1.tsv','cardiovascular-HealthKitDataCollector-v1.tsv','cardiovascular-motionTracker-v1.tsv','cardiovascular-motionActivityCollector-v1.tsv','cardiovascular-HealthKitWorkoutCollector-v1.tsv','cardiovascular-HealthKitSleepCollector-v1.tsv','cardiovascular-6-Minute Walk Test_SchemaV4-v1.tsv']

csv_formats=['cardiovascular-ActivitySleep-v1.tsv','cardiovascular-daily_check-v1.tsv','cardiovascular-Diet_survey_cardio-v1.tsv','cardiovascular-par-q quiz-v1.tsv','cardiovascular-risk_factors-v1.tsv','cardiovascular-satisfied-v1.tsv']  

blob_json_formats=['cardiovascular-6MinuteWalkTest-v2.tsv','cardiovascular-6MWT Displacement Data-v1.tsv']


blob_csv_formats=['cardiovascular-HealthKitDataCollector-v1.tsv','cardiovascular-motionTracker-v1.tsv','cardiovascular-displacement-v1.tsv','cardiovascular-motionActivityCollector-v1.tsv','cardiovascular-HealthKitWorkoutCollector-v1.tsv','cardiovascular-HealthKitSleepCollector-v1.tsv'] 


#valid header files for blob objects 
blob_headers=dict() 
blob_headers['cardiovascular-displacement-v1.tsv']='startTime\tendTime\ttype\tvalue\tunit\tsource\tsourceIdentifier'
blob_headers['cardiovascular-motionTracker-v1.tsv']="dateAndTime\tactivityTypeName\tactivityTypeValue\tconfidenceName\tconfidenceRaw\tconfidencePercent"
blob_headers['cardiovascular-motionActivityCollector-v1.tsv']="startTime\tActivityType\tConfidence" 
blob_headers['cardiovascular-HealthKitDataCollector-v1.tsv']="datetime\ttype\tvalue"
blob_headers['cardiovascular-HealthKitWorkoutCollector-v1.tsv']="startTime\tendTime\ttype\tworkoutType\ttotal distance\tunit\tenergy consumed\tunit\tsource\tsourceIdentifier\tmetadata"
blob_headers['cardiovascular-HealthKitSleepCollector-v1.tsv']="startTime\ttype\tcategory value\tvalue\tunit\tsource\tsourceIdentifier" 

#IMPUTED AGE & SEX
imputed=basedir+table_dir+"derived_age_sex_prediction.tsv" 
