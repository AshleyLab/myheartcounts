#for chrom in `seq 1 22` X
#do
#    for i in `cat fields.continuous.cleanedupskew`
#    do 
#	sbatch -J $i.$chrom -o logs/$i.$chrom.o -e logs/$i.$chrom.e -p euan,akundaje,owners,normal plink_script_continuous.cleanedupskew.sh $i $chrom
#    done
#done

for chrom in `seq 1 22` X
do
    for i in `cat fields.continuous.cleanedupskew2`
    do 
	sbatch -J $i.$chrom -o logs/$i.$chrom.o -e logs/$i.$chrom.e -p euan,akundaje,owners,normal plink_script_continuous.cleanedupskew.sh $i $chrom
    done
done
