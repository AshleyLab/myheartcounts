sbatch -J "filter_app_version_hk" -o logs/hk.o -e logs/hk.e -p euan,owners --time=24:00:00  --mem=10G  filter_subject_date_version.sh

sbatch -J "filter_app_version_motion" -o logs/motion.o -e logs/motion.e -p euan,owners --time=24:00:00  --mem=10G  filter_subject_date_version_motion.sh
