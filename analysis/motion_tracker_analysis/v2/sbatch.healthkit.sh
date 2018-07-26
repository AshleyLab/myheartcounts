#DataCollector:
for subject_subset in `seq 0 453`

#Workouts 
#for subject_subset in `seq 0 310`


#Sleep 
#for subject_subset in `seq 0 155` 
do
    sbatch -J "healthkit$subject_subset" -o logs2/healthkit.$subject_subset.o -e logs2/healthkit.$subject_subset.e -p euan get_activity_fraction_and_duration_appv2.healthkit.sh $subject_subset
done
