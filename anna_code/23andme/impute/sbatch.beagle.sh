#for chrom in `seq 1 22` X MT
for chrom in 2
do
    sbatch -J beagle.$chrom --ntasks=1 --cpus-per-task=10 -o logs/beagle.$chrom.o -e logs/beagle.$chrom.e -p euan,akundaje,owners --mem=50G -t 1-0 run_beagle.sh $chrom
done
