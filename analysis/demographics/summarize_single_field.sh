#python summarize_single_field.py --input demographics_summary_v1.tsv --field age --outf demographics_summary_v1.age.tsv
#python summarize_single_field.py --input demographics_summary_v1.tsv --field sex --outf demographics_summary_v1.sex.tsv
#python summarize_single_field.py --input demographics_summary_v1.tsv --field race --outf demographics_summary_v1.race.tsv
#python summarize_single_field.py --input /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-risk_factors_SchemaV2-v1.tsv --field generic --outf demographics_summary_v1.education.tsv --version_index 2 --version 1 --field_index -1 --field_values Didn\'t\ go\ to\ school Gradeschool High\ school\ diploma\ or\ G.E.D Some\ college\ or\ vocational\ school\ or\ associate\ degree College\ Graduate\ or\ Baccalaureate\ Degree Master\'s\ Degree Doctoral\ Degree  --field_keys 1 2 3 4 5 6 7

python summarize_single_field.py --input /scratch/PI/euan/projects/mhc/data/tables/cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv --field generic --outf demographics_summary_v1.smoking.tsv --version_index 6 --version 1 --field_index 20 --field_keys TRUE FALSE --field_values TRUE FALSE
