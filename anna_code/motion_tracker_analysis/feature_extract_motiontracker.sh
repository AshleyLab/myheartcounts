var1=$SGE_TASK_ID 
var2=$((var1 + 99))
echo $var1 
echo $var2 
Rscript feature_extract_motiontracker.R $var1 $var2