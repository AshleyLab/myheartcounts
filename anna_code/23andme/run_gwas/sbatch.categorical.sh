for i in `cat fields.categorical`
do 
    sbatch -J $i -o logs/$i.o -e logs/$i.e -p euan plink_script_categorical.sh $i
done
