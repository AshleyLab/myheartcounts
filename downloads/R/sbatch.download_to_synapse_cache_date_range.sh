#!/bin/bash
start_date='2018-10-03'
for table in syn4095792 syn3560095 syn4536838 syn3420486 syn21052093 syn20563457  #syn3560085
do
    sbatch -J download.$table -o logs/$table.o -e logs/$table.e --time=1440 -p akundaje,euan,owners,normal  download_to_synapse_cache_date_range.wrapper.sh $table $start_date  
done
