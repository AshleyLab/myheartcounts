#education levels 
#python summarize_single_field.py --input /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-risk_factors_SchemaV2-v1.tsv --field education --outf education.rct.tsv  --output_field_vals 

#physical activity readiness questionnaire 
python summarize_single_field.py --input /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-par-q-quiz-v1.tsv --field chestPain chestPainInLastMonth dizziness heartCondition jointProblem physicallyCapable prescriptionDrugs --outf parq --output_field_vals 


#python summarize_single_field.py --input demographics_summary_v1.tsv --field age --outf demographics_summary_v1.age.tsv
#python summarize_single_field.py --input demographics_summary_v1.tsv --field sex --outf demographics_summary_v1.sex.tsv
#python summarize_single_field.py --input demographics_summary_v1.tsv --field race --outf demographics_summary_v1.race.tsv

#python summarize_single_field.py --input /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-risk_factors_SchemaV2-v1.tsv --field generic --outf demographics_summary_v1.education.tsv --version_index 2 --version 1 --field_index -1 --field_values Didn\'t\ go\ to\ school Gradeschool High\ school\ diploma\ or\ G.E.D Some\ college\ or\ vocational\ school\ or\ associate\ degree College\ Graduate\ or\ Baccalaureate\ Degree Master\'s\ Degree Doctoral\ Degree  --field_keys 1 2 3 4 5 6 7

#python summarize_single_field.py --input /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv --field generic --outf demographics_summary_v1.smoking.tsv --version_index 6 --version 1 --field_index 20 --field_keys TRUE FALSE --field_values TRUE FALSE

#smoking status, irrespective of version 
#python summarize_single_field.py --input /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv --field generic --outf smoking.1.tsv  --field_index 20 --field_keys TRUE FALSE --field_values TRUE FALSE --output_field_vals --health_code_index 2

#python summarize_single_field.py --input /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2.tsv --field generic --outf smoking.2.tsv --field_index 24 --field_keys TRUE FALSE --field_values TRUE FALSE --output_field_vals --health_code_index 5

#python summarize_single_field.py --input /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-heart_risk_and_age-v1.tsv --field generic --outf smoking.3.tsv --field_index 23 --field_keys TRUE FALSE --field_values TRUE FALSE --output_field_vals --health_code_index 5

#Height & Weight 
#prefix=/scratch/PI/euan/projects/mhc/data/tables/
#python summarize_single_field.py --inputs $prefix/cardiovascular-NonIdentifiableDemographicsTask-v2.tsv $prefix/cardiovascular-NonIdentifiableDemographics-v1.tsv --fields NonIdentifiableDemographics.patientWeightPounds NonIdentifiableDemographics.patientHeightInches  --version "version 2" --output_field_vals --outf version2

#Smoking
#python summarize_single_field.py --inputs $prefix/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2.tsv  $prefix/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv $prefix/cardiovascular-heart_risk_and_age-v1.tsv --fields smokingHistory   --version "version 2" --output_field_vals --outf smoking

#Heart Disease
#python summarize_single_field.py --inputs $prefix/cardiovascular-risk_factors_SchemaV2-v1.tsv  $prefix/cardiovascular-risk_factors-v1.tsv  --fields heart_disease   --version "version 2" --output_field_vals --outf heart_disease


#Vascular Disease 
#python summarize_single_field.py --inputs $prefix/cardiovascular-risk_factors_SchemaV2-v1.tsv  $prefix/cardiovascular-risk_factors-v1.tsv  --fields vascular   --version "version 2" --output_field_vals --outf vascular

#Family History
#python summarize_single_field.py --inputs $prefix/cardiovascular-risk_factors_SchemaV2-v1.tsv  $prefix/cardiovascular-risk_factors-v1.tsv  --fields family_history   --version "version 2" --output_field_vals --outf family_history

#Medications 
#python summarize_single_field.py --inputs $prefix/cardiovascular-risk_factors_SchemaV2-v1.tsv  $prefix/cardiovascular-risk_factors-v1.tsv  --fields medications_to_treat   --version "version 2" --output_field_vals --outf medications

#zip code 
#python summarize_single_field.py --inputs $prefix/cardiovascular-satisfied-v1.tsv  $prefix/cardiovascular-satisfied_SchemaV3-v1.tsv  $prefix/cardiovascular-satisfied_SchemaV2-v1.tsv  --fields zip   --output_field_vals --outf zipcode
