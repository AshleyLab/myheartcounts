#education levels 
python summarize_single_field.py --input /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-risk_factors_SchemaV2-v1.tsv --field education --outf education.all.interventions.rct.tsv --subjects /scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt --output_field_vals 

#physical activity readiness questionnaire 
python summarize_single_field.py --input /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-par-q-quiz-v1.tsv --field chestPain chestPainInLastMonth dizziness heartCondition jointProblem physicallyCapable prescriptionDrugs --outf parq --output_field_vals --subjects /scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt


python summarize_single_field.py --input ../demographics_summary_v1.tsv --field age --outf demographics_summary_v1.age.tsv --subjects /scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt
python summarize_single_field.py --input ../demographics_summary_v1.tsv --field sex --outf demographics_summary_v1.sex.tsv --subjects /scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt
python summarize_single_field.py --input ../demographics_summary_v1.tsv --field race --outf demographics_summary_v1.race.tsv --subjects /scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt



#Height & Weight 
prefix=/scratch/PI/euan/projects/mhc/data/tables/
python summarize_single_field.py --inputs $prefix/cardiovascular-NonIdentifiableDemographicsTask-v2.tsv $prefix/cardiovascular-NonIdentifiableDemographics-v1.tsv --fields NonIdentifiableDemographics.patientWeightPounds NonIdentifiableDemographics.patientHeightInches   --outf all.interventions --subjects /scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt

#Smoking
python summarize_single_field.py --inputs $prefix/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2.tsv  $prefix/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv $prefix/cardiovascular-heart_risk_and_age-v1.tsv --fields smokingHistory   --outf smoking --subjects /scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt

#Heart Disease
python summarize_single_field.py --inputs $prefix/cardiovascular-risk_factors_SchemaV2-v1.tsv  $prefix/cardiovascular-risk_factors-v1.tsv  --fields heart_disease  --outf heart_disease --subjects /scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt


#Vascular Disease 
python summarize_single_field.py --inputs $prefix/cardiovascular-risk_factors_SchemaV2-v1.tsv  $prefix/cardiovascular-risk_factors-v1.tsv  --fields vascular   --outf vascular --subjects /scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt

#Family History
python summarize_single_field.py --inputs $prefix/cardiovascular-risk_factors_SchemaV2-v1.tsv  $prefix/cardiovascular-risk_factors-v1.tsv  --fields family_history --outf family_history --subjects /scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt

#Medications 
python summarize_single_field.py --inputs $prefix/cardiovascular-risk_factors_SchemaV2-v1.tsv  $prefix/cardiovascular-risk_factors-v1.tsv  --fields medications_to_treat --output_field_vals --outf medications  --subjects /scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt

#zip code 
#python summarize_single_field.py --inputs $prefix/cardiovascular-satisfied-v1.tsv  $prefix/cardiovascular-satisfied_SchemaV3-v1.tsv  $prefix/cardiovascular-satisfied_SchemaV2-v1.tsv  --fields zip   --output_field_vals --outf zipcode
