#for i in `seq 1 7248`
sbatch -J "workout_collector" -o workout.o -e workout.e -p euan,owners --time=24:00:00 assemble_motion.sh $i
