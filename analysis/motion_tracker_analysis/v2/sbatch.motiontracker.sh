for subject_set in `seq 0 353`
do
    sbatch -J "motiontracker$subject_set" -o logs2/motiontracker.$subject_set.o -e logs2/motiontracker.$subject_set.e -p euan get_activity_fraction_and_duration_appv2.activity_only.sh $subject_set
done
