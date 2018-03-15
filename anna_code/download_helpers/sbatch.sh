for task in `seq 1 8`
do
    sbatch -J "$task.get.missing" -o logs/$task.o -e logs/$task.e -p akundaje find_blob_files_to_download.sh $task
done
