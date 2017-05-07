#for subject_subset in `seq 0 135`
for subject_subset in 119 23 29 55 7 84 86
do
    sbatch -J "healthkit$subject_subset" -o logs/healthkit.$subject_subset.o -e logs/healthkit.$subject_subset.e -p euan,owners get_activity_fraction_and_duration_appv2.healthkit.sh $subject_subset
done
