var1=$SGE_TASK_ID 
var2=$((var1 + 49))
echo $var1 
echo $var2 
Rscript feature_extract_6min_walk.R $var1 $var2