#!/bin/bash
#SBATCH -J "parseHKSplit"       # job name
#SBATCH -o ./parsedActivityLinesLogs/split_%a.out
#SBATCH -e ./parsedActivityLinesLogs/split_%a.error
#SBATCH -t 00:60:00
#SBATCH --qos normal
#SBATCH -p euan,owners,normal
#SBATCH --ntasks=1            # number of processor cores (i.e. tasks)
#SBATCH --nodes=1             # number of nodes
#SBATCH --array=0-600           # job array of size 2

python parseActivityLines.py -idxPath indices600 -line ${SLURM_ARRAY_TASK_ID}
