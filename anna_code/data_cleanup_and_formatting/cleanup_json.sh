echo $SGE_TASK_ID 
var1=$SGE_TASK_ID 
var2=$((var1 + 99))
echo $var1 
echo $var2 
python cleanup_json.py  -start $var1 -end $var2 
