for subject_set in `seq 0 104`
do
    sbatch -J "motiontracker$subject_set" -o logs/motiontracker.$subject_set.o -e logs/motiontracker.$subject_set.e -p euan,owners get_activity_fraction_and_duration_appv2.activity_only.sh $subject_set
done
