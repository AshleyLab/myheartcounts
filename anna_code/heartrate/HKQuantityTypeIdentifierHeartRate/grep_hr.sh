#!/bin/bash 
grep -R -w "HKQuantityTypeIdentifierHeartRate" /scratch/PI/euan/projects/mhc/data/synapseCache/$1/* >> $1.o
