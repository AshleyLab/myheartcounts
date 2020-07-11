prefix="/oak/stanford/groups/euan/projects/mhc/data/tables/"
tables=( cardiovascular-HealthKitDataCollector-v1.tsv cardiovascular-HealthKitWorkoutCollector-v1.tsv cardiovascular-HealthKitSleepCollector-v1.tsv cardiovascular-motionActivityCollector-v1.tsv watchMotionActivityCollector-v1.tsv )
for table in "${tables[@]}"
do
   head -n1 $prefix/$table > $prefix/2.3.2/$table
   grep "version 2.3.2" $prefix/$table >> $prefix/2.3.2/$table 
   echo $table
done

