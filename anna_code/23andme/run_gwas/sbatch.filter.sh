for field in `cat fields.continuous`
do
    sbatch -J "filter$field" -o logs/filter.$field.o -e logs/filter.$field.e -p euan,akundaje,owners filter.continuous.sh $field
done

for field in `cat fields.categorical`
do 
    sbatch -J "filter$field" -o logs/filter.$field.o -e logs/filter.$field.e -p euan,akundaje,owners filter.categorical.sh $field
done
