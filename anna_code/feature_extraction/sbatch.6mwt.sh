for t in `seq 1 50 5000` 
do  
    sbatch -J $t -o logs/$t.o -e logs/$t.e -p euan,owners feature_extract_6min_walk.sh $t 
done
