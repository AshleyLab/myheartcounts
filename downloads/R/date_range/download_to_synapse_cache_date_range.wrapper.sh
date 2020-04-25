#!/bin/bash 
module load R
Rscript download_to_synapse_cache_date_range.R $1 $2 
