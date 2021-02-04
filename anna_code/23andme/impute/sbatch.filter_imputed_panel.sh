for chrom in `seq 1 22` X MT
do
    sbatch -J filter.imputed.$chrom --ntasks=1 --cpus-per-task=10 -o logs/filter.imputed.$chrom.o -e logs/filter.imputed.$chrom.e -p euan,akundaje,owners --mem=5G  filter_imputed_panel.sh $chrom

done
