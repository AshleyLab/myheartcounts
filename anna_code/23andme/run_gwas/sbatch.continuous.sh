for i in `cat fields.continuous`
do 
    sbatch -J $i -o logs/$i.o -e logs/$i.e -p euan plink_script_continuous.sh $i
done
