module load R
#for field in `ls results_filtered/*linear`
#do
#    field=`basename $field`
#    echo $field 
#    sbatch -J "significant$field" -o logs/significant.$field.o -e logs/significant.$field.e -p euan,akundaje,owners --mem=10000 significant.sh results_filtered/$field 5e-6
#done

for field in `ls results_filtered/*logistic.hybrid`
do 
    field=`basename $field`
    echo $field
    sbatch -J "significant$field" -o logs/significant.$field.o -e logs/significant.$field.e -p euan,akundaje,owners --mem=50000 significant.categorical.sh results_filtered/$field 5e-6
done
