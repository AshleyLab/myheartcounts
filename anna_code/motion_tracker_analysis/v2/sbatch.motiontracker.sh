#motionTracker, all versions 
#for subject_set in `seq 0 1840`
#motionActivity, all versions 
#for subject_set in `seq 0 1221`
for subject_set in 0 
do
    sbatch -J "motiontracker$subject_set" -o logs2/motiontracker.new.$subject_set.o -e logs2/motiontracker.new.$subject_set.e -t 3-0 --qos normal -p akundaje get_activity_fraction_and_duration_appv2.activity_only.sh $subject_set
done
