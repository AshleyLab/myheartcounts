for i in `seq 0 630`
do
    sbatch -J "find_ukbb_rep" -o logs/$i.o -e logs/$i.e -p euan,owners search_ukbb.sh $i
done
