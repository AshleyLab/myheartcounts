var1=$SGE_TASK_ID 
var2=$((var1 + 19))
echo $var1 
echo $var2 
python hr_variance_and_early.py $var1 $var2