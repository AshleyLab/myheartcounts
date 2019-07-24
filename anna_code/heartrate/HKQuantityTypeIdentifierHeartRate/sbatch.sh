for i in `seq 902 999` 
do 
    sbatch -J hkhr.$i -o logs/$i.o -e logs/$i.e -p euan,normal,owners,akundaje grep_hr.sh $i 
done

