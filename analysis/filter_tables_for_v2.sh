#filter tables in parent directory to only include v2 data
#for f in ../../data/tables/cardiovascular*
#do
#    echo $f
#    MYBASENAME="$(basename "$f")"
#    grep "version 2" $f > "../../data/tables/v2_data_subset/$MYBASENAME"
#done


#update healthkit & motion tracker subject lists for intervention effect analysis 
python get_unique.py --source_files ../../data/tables/v2_data_subset/*HealthKit* --outf ../../data/tables/v2_data_subset/subjects/healthkit_data/subjects

python get_unique.py --source_files ../../data/tables/v2_data_subset/*motion* --outf ../../data/tables/v2_data_subset/subjects/motion/subjects

