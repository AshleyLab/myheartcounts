module load R 
for field in `ls results_filtered/*linear`
do
    field=`basename $field`
   echo $field 
    sbatch -J "plot$field" -o logs/plot.$field.o -e logs/plot.$field.e -p euan,akundaje,owners --mem=50000 vis.sh $field
done

for field in `ls results_filtered/*logistic`
do 
    field=`basename $field`
    echo $field
    sbatch -J "plot$field" -o logs/plot.$field.o -e logs/plot.$field.e -p euan,akundaje,owners --mem=50000 vis.categorical.sh $field
done
