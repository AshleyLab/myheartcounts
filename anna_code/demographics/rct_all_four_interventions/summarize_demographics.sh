
#ALL VERSIONS (i.e. no start or end date specified) 
PREFIX=/scratch/PI/euan/projects/mhc/data/tables
python summarize_demographics.py --summary_tables $PREFIX/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv $PREFIX/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2.tsv $PREFIX/cardiovascular-heart_risk_and_age-v1.tsv $PREFIX/cardiovascular-NonIdentifiableDemographicsTask-v2.tsv \
    --outf demographics_summary.tsv \
    --subjects /scratch/PI/euan/projects/mhc/code/anna_code/rct/subjects_who_did_all_four_interventions/subjects.who.did.all.four.interventions.txt
