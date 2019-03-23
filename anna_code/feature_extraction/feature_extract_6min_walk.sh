var1=$1
var2=$((var1 + 49))
echo $var1 
echo $var2 
Rscript feature_extract_6min_walk.R $var1 $var2
