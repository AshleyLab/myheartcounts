#for chrom in `seq 1 22` X MT
for chrom in 2
do
    sbatch -J conform_gt.$chrom -o logs/conform_gt.$chrom.o -e logs/conform_gt.$chrom.e -p euan,akundaje,owners --mem=50G conform_gt.sh $chrom
done
