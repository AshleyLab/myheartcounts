echo $SGE_TASK_ID 
var1=$SGE_TASK_ID 
var2=$((var1 + 499))
echo $var1 
echo $var2 
python cleanup.py  $var1 $var2
