for i in `seq 1 21` X
#for i in 22
do
    sbatch -J "$i" -o logs/$i.o -e logs/$i.e -p euan,owners --mem=40000 find_ld.sh $i
done

