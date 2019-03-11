#!/bin/bash
##
#SBATCH --job-name=process_data
##################
#SBATCH -x sh-113-15
##################
##a file for job output, you can check job progress, append the job ID with %j to make it uniqueß
#SBATCH --output=process_data.out
##################
## a file for errors from the job
#SBATCH --error=process_data.err
##################
##time you think you need; default is 2 hours
##format could be dd-hh:mm:ss, hh:mm:ss, mm:ss, or mm
#SBATCH --time=48:00:00
##################
## Quality of Service (QOS); think of it as sending your job into a special queue; --qos=long for with a max job length of 7 days.
## uncomment #SBATCH -p "long" if you want your job to run longer than 48 hours, the default for normal partition,
## NOTE- in the hns partition the default max run time is 7 days , so you wont need to include qos
## We are submitting to the dev partition, there are several on sherlock: normal, gpu, bigmem (jobs requiring >64Gigs RAM)
#SBATCH -p euan
##################
##number of nodes you are requesting, the more you ask for the longer you wait
#SBATCH --nodes=8
##################
## --mem is memory per node; default is 4000 MB per CPU, remember to ask for enough mem to match your CPU request, since
## sherlock automatically allocates 4 Gigs of RAM/CPU, if you ask for 8 CPUs you will get 32 Gigs of RAM, so either
## leave --mem commented out or request >= to the RAM needed for your CPU request.  It will also accept mem. in units, ie "--mem=4G"
## SBATCH --mem=32G

##################
#SBATCH --mail-type=END,FAIL # notifications for job done & fail
# Remember to change this to your email
#SBATCH --mail-user=danjwu@stanford.edu
##################
cd /scratch/users/danjwu/code
python process_data.py