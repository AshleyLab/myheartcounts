sbatch -J "6mwt_parse" -o logs/6mwt.o -e logs/6mwt.e -p euan --time=24:00:00 assemble_6mwt.sh



#for i in `seq 1 7248`
#for i in `seq 2 2486`
#do
#    sbatch -J "6mwt" -o logs/6mwt.$i.o -e logs/6mwt.$i.e -p euan,owners --nodes 1 --qos=long --time=24:00:00 --mem=10000 assemble_6mwt.sh $i
#done
