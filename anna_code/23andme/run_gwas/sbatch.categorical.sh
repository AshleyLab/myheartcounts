for i in `cat fields.categorical`
do 
    sbatch -J $i -o logs/$i.o -e logs/$i.e -p akundaje plink_script_categorical.sh $i
done
