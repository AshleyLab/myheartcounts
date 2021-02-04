#for field in `cat fields.continuous`
#do
#    sbatch -J "clump$field" -o logs/clump.$field.o -e clump/filter.$field.e -p euan,akundaje,owners clump.sh $field.linear
#done

for field in `cat fields.binarized`
do 
    sbatch -J "clump$field" -o logs/clump.$field.o -e logs/clump.$field.e -p euan,akundaje,owners clump.sh $field.glm.logistic.hybrid
done
