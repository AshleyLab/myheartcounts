#!/bin/bash
#SBATCH -J "parseHKSplit"       # job name
#SBATCH -o ./activityLinesLogs/split_%a.out
#SBATCH -e ./activityLinesLogs/split_%a.error
#SBATCH -t 00:30:00
#SBATCH --qos normal
#SBATCH -p euan,owners,normal
#SBATCH --ntasks=1            # number of processor cores (i.e. tasks)
#SBATCH --nodes=1             # number of nodes
#SBATCH --array=0-600           # job array of size 2

python gatherStepCountData.py -idxFile indices600 -line ${SLURM_ARRAY_TASK_ID}
