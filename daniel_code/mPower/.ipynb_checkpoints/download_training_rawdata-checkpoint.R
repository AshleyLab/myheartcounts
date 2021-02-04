#source("http://depot.sagebase.org/CRAN.R")
#pkgInstall(c("synapseClient"))

#source("~/mybiotools/r/", echo=T)
rm(list=ls());
options("scipen"=1, "digits"=4, stringsAsFactors=FALSE);
# Walk feature extraction for training data: demographics:syn10146552 , table:syn10146553

#library(synapseClient)
library(synapser)
# synapseLogin()
synLogin()


library(plyr)
library(dplyr)
library(ggplot2)
library(doMC)
library(jsonlite)
library(parallel)
library(tidyr)
library(lubridate)
library(stringr)
library(sqldf)
library(mpowertools) 

# read in the healthCodes of interest from demographics training table
demo_syntable <- synTableQuery("SELECT * FROM syn10146552")
demo <- demo_syntable@values
save(demo, file="demo.rdata")
healthCodeCol <- c(as.character(demo$healthCode))
healthCodeList <- paste0(sprintf("'%s'", healthCodeCol), collapse = ", ")

# Query table of interest, walking training table
INPUT_WALKING_ACTIVITY_TABLE_SYNID = 'syn10146553'
#!!actv_walking_syntable <- synTableQuery(paste0("SELECT 'recordId', 'healthCode','deviceMotion_walking_outbound.json.items' FROM ", INPUT_WALKING_ACTIVITY_TABLE_SYNID, " WHERE healthCode IN ", "(", healthCodeList, ")"))
actv_walking_syntable <- synTableQuery(paste0("SELECT * FROM  ", INPUT_WALKING_ACTIVITY_TABLE_SYNID, " WHERE healthCode IN ", "(", healthCodeList, ")"))
actv_walking <- actv_walking_syntable@values
actv_walking$idx <- rownames(actv_walking)
save(actv_walking, file="actv_walking.rdata")

# save for later
selected_records <- actv_walking$recordId

######################
# Download JSON Files
######################
#download outbound walking json files
DL_headers = colnames(actv_walking)[6:13]
json_files = list()
#!!outbound_Walking_json_files <- synDownloadTableColumns(actv_walking_syntable, "deviceMotion_walking_outbound.json.items")
for (name in DL_headers) {
	cat ("Downloading ", name, "\n")
	outbound_Walking_json_files <- synDownloadTableColumns(actv_walking_syntable, name)
	outbound_Walking_json_files <- data.frame(outbound_Walking_json_fileId =names(outbound_Walking_json_files),
											  outbound_Walking_json_file = as.character(outbound_Walking_json_files))
	outbound_Walking_json_files <- outbound_Walking_json_files %>%
	distinct(outbound_Walking_json_file, .keep_all = TRUE)
	json_files[[length(json_files)+1]] = outbound_Walking_json_files
}
save(json_files, file="json_files.rdata")

outbound_Walking_json_files <- synDownloadTableColumns(actv_walking_syntable, DL_headers)
outbound_Walking_json_files <- data.frame(outbound_Walking_json_fileId =names(outbound_Walking_json_files),
										  outbound_Walking_json_file = as.character(outbound_Walking_json_files))
outbound_Walking_json_files <- outbound_Walking_json_files %>%
distinct(outbound_Walking_json_file, .keep_all = TRUE)
save(outbound_Walking_json_files, file="outbound_Walking_json_files.rdata")

