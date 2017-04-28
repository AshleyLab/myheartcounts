#filter tables in parent directory to only include v2 data
for f in ../cardiovascular*
do
    echo $f
    basename="${f##*/}"
    grep "version 2" $f > $basename
done
#get copy list
