sbatch -J "download" -o logs/download.o -e logs/download.e -p akundaje,euan --time=4-00:00:00 download.sh
