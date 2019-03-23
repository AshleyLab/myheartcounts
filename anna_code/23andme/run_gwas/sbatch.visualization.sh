for field in `cat fields.continuous`
do
    sbatch -J "plot$field" -o logs/plot.$field.o -e logs/plot.$field.e -p euan,akundaje,owners --mem=10000 vis.sh $field
done

for field in `cat fields.categorical`
do 
    sbatch -J "plot$field" -o logs/plot.$field.o -e logs/plot.$field.e -p euan,akundaje,owners --mem=10000 vis.categorical.sh $field
done
