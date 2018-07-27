#DataCollector: (not split by appVersion) 
#for subject_subset in `seq 0 1572`

#Workouts 
#for subject_subset in `seq 0 310`


#Sleep 
#for subject_subset in `seq 0 155` 

#all in 1 
for subject_subset in 0 
do
    sbatch -J "healthkit$subject_subset" -o logs2/healthkit.$subject_subset.o -e logs2/healthkit.$subject_subset.e -p akundaje get_activity_fraction_and_duration_appv2.healthkit.sh  $subject_subset
done
