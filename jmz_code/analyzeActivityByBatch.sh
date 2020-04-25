#!/bin/sh
#SBATCH -J "activityParse"
#SBATCH -o ./logs/job_%A_batch_%a.out
#SBATCH -e ./logs/job_%A_batch_%a.error
#SBATCH -t 10:00:00
#SBATCH --qos normal
#SBATCH -p euan,owners,normal
#SBATCH --ntasks=1
#SBATCH --nodes=1             # number of nodes
#SBATCH --array=1-701           # job array of size 702

python getActivitySummaryByIdx.py --writePath activitiesMay18 --indexFilePath ./activitySplitMay18 --listIdx ${SLURM_ARRAY_TASK_ID}
