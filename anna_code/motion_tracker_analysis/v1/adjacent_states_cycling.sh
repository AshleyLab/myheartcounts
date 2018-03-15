echo $SGE_TASK_ID 
var1=$SGE_TASK_ID 
var2=$((var1 + 19))
echo $var1 
echo $var2 
#var2=expr $SGE_TASK_ID *20 
#var2=expr $var2 - 1 
python adjacent_states_cycling.py $var1 $var2