for field in `cat fields.continuous`
do
    sbatch -J "remove_hash$field" -o logs/remove_hash.$field.o -e logs/remove_hash.$field.e -p euan,akundaje,owners remove_hash.sh results_filtered/$field.linear
done

#for field in `cat fields.binarized`
#do 
#    sbatch -J "remove_hash$field" -o logs/remove_hash.$field.o -e logs/remove_hash.$field.e -p euan,akundaje,owners remove_hash.sh results_filtered/$field.glm.logistic.hybrid
#done
