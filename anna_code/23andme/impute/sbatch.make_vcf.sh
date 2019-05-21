sbatch -J make_vcf -o logs/make_vcf.o -e logs/make_vcf.e -p euan,akundaje,owners --mem=50G make_vcf.sh
