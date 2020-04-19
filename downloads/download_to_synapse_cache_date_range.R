#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
cur_table_id=args[1]
start_date=args[2]
print(cur_table_id)
print(start_date)
library("RSQLite")
library("parallel")
library("synapser")
cache.path <- "/oak/stanford/groups/euan/projects/mhc/data/synapseCache/"  #"/scratch/PI/euan/projects/mhc/data/synapseCache/"
projectId="syn3270436"
synLogin()
query=paste("select * from ",cur_table_id, " where createdOn >'",start_date,"'",sep='')
print(query)
sq=synTableQuery(query);
cur_table_columns=as.list(synGetTableColumns(sq))
for(j in seq(1,length(cur_table_columns)))
{
  if(cur_table_columns[[j]]$columnType=="FILEHANDLEID")
  {
    cur_table_column_id=cur_table_columns[[j]]$id
    cur_table_column_name=cur_table_columns[[j]]$name
    print(paste("Downloading column",cur_table_column_name,"from table",cur_table_id,sep=' '))
    synDownloadTableColumns(sq,columns=list(cur_table_column_name))
  }
}
print("done!")
