for section in `seq 0 10000 1180991`
do
    sbatch -J "$section" -o logs/$section.o -e logs/$section.e -p euan,owners aws_parser.sh $section
done
