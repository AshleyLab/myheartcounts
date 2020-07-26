prefix="/oak/stanford/groups/euan/projects/mhc/data/tables"

cut -f7 $prefix/2.3.2/cardiovascular-HealthKitDataCollector-v1.tsv | sort |uniq | grep -v "healthCode" > $prefix/2.3.2/subjects/hk_data_collector/hk.datacollector 
rm  $prefix/2.3.2/subjects/hk_data_collector/x*
split -a3 -d -l10 $prefix/2.3.2/subjects/hk_data_collector/hk.datacollector $prefix/2.3.2/subjects/hk_data_collector/x
rename x0 x  $prefix/2.3.2/subjects/hk_data_collector/x*
rename x0 x  $prefix/2.3.2/subjects/hk_data_collector/x*
sed -i 's/\"//g' $prefix/2.3.2/subjects/hk_data_collector/x*

cut -f7 $prefix/2.3.2/cardiovascular-HealthKitWorkoutCollector-v1.tsv | sort |uniq | grep -v "healthCode" > $prefix/2.3.2/subjects/hk_workout/hk.workout
rm  $prefix/2.3.2/subjects/hk_workout/x*
split -a3 -d -l10 $prefix/2.3.2/subjects/hk_workout/hk.workout $prefix/2.3.2/subjects/hk_workout/x
rename x0 x  $prefix/2.3.2/subjects/hk_workout/x*
rename x0 x  $prefix/2.3.2/subjects/hk_workout/x*
sed -i 's/\"//g' $prefix/2.3.2/subjects/hk_workout/x*

cut -f7 $prefix/2.3.2/cardiovascular-HealthKitSleepCollector-v1.tsv | sort |uniq | grep -v "healthCode" > $prefix/2.3.2/subjects/hk_sleep/hk.sleep
rm  $prefix/2.3.2/subjects/hk_sleep/x*
split -a3 -d -l10 $prefix/2.3.2/subjects/hk_sleep/hk.sleep $prefix/2.3.2/subjects/hk_sleep/x
rename x0 x $prefix/2.3.2/subjects/hk_sleep/x*
rename x0 x $prefix/2.3.2/subjects/hk_sleep/x*
sed -i 's/\"//g' $prefix/2.3.2/subjects/hk_sleep/x* 

cut -f7 $prefix/2.3.2/cardiovascular-motionActivityCollector-v1.tsv | sort |uniq | grep -v "healthCode" > $prefix/2.3.2/subjects/motion_phone/motion.activity.phone
rm  $prefix/2.3.2/subjects/motion_phone/x*
split -a3 -d -l10 $prefix/2.3.2/subjects/motion_phone/motion.activity.phone $prefix/2.3.2/subjects/motion_phone/x
rename x0 x $prefix/2.3.2/subjects/motion_phone/x*
rename x0 x $prefix/2.3.2/subjects/motion_phone/x*
sed -i 's/\"//g' $prefix/2.3.2/subjects/motion_phone/x*

cut -f7 $prefix/2.3.2/watchMotionActivityCollector-v1.tsv | sort |uniq | grep -v "healthCode" > $prefix/2.3.2/subjects/motion_watch/motion.activity.watch
rm  $prefix/2.3.2/subjects/motion_watch/x*
split -a3 -d -l10 $prefix/2.3.2/subjects/motion_watch/motion.activity.watch $prefix/2.3.2/subjects/motion_watch/x
rename x0 x $prefix/2.3.2/subjects/motion_watch/x*
rename x0 x $prefix/2.3.2/subjects/motion_watch/x*
sed -i 's/\"//g' $prefix/2.3.2/subjects/motion_watch/x*


