#VERSION 1 (end date specified) 
#python summarize_demographics.py --summary_tables /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2.tsv /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-heart_risk_and_age-v1.tsv /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-NonIdentifiableDemographicsTask-v2.tsv \
#    --outf demographics_summary_v1.tsv \
#    --end_date 2016-10-02


#VERSION 2  (start date specified) 
#PREFIX=/scratch/PI/euan/projects/mhc/data/tables
#python summarize_demographics.py --summary_tables $PREFIX/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv $PREFIX/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2.tsv $PREFIX/cardiovascular-heart_risk_and_age-v1.tsv $PREFIX/cardiovascular-NonIdentifiableDemographicsTask-v2.tsv \
#    --outf demographics_summary_v2.tsv \
#    --start_date 2016-12-07


#ALL VERSIONS (i.e. no start or end date specified) 
PREFIX=/scratch/PI/euan/projects/mhc/data/tables
python summarize_demographics.py --summary_tables $PREFIX/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv $PREFIX/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v2.tsv $PREFIX/cardiovascular-heart_risk_and_age-v1.tsv $PREFIX/cardiovascular-NonIdentifiableDemographicsTask-v2.tsv \
    --outf demographics_summary_v1_v2.tsv 
