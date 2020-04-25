### PREAMBLE ######################################################################################
#install.packages("synapser", repos=c("http://ran.synapse.org", "http://cran.fhcrc.org"))
#install.packages("RSQLite") 
#note: modify ~/.synapseConfig to set [cache] to cache.path below 
library("RSQLite")
library("parallel")
library("synapser")


data.path <- "/oak/stanford/groups/euan/projects/mhc/data/tables/" #"/scratch/PI/euan/projects/mhc/data/tables/"
#note: synapser does not have functionality to change cache.path; do this by modifying the ~/.synapseConfig file
cache.path <- "/oak/stanford/groups/euan/projects/mhc/data/synapseCache/"  #"/scratch/PI/euan/projects/mhc/data/synapseCache/"
projectId="syn3270436"
synLogin() 

#get the tables 
tables <- synGetChildren(projectId,includeTypes=c("table","file"))
tables=as.list(tables) 
#print(tables) 
for(i in seq(1,length(tables)))
{
	cur_table=tables[[i]]
	cur_table_id=cur_table$id 
	cur_table_name=cur_table$name 
	print(paste0(cur_table_id,":",cur_table_name))
	outfname=paste(data.path,cur_table_name,".tsv",sep='')
	sq=synTableQuery(paste('select * from',cur_table_id,sep=' '))
	write.table(sq$asDataFrame(), file=outfname, quote=F,sep="\t",row.names=T)	    #check for any columns that are of type FILEHANDLEID 
	cur_table_columns=as.list(synGetTableColumns(sq))
	for(j in seq(1,length(cur_table_columns)))
        {
	if(cur_table_columns[[j]]$columnType=="FILEHANDLEID")	
	{
        cur_table_column_id=cur_table_columns[[j]]$id
        cur_table_column_name=cur_table_columns[[j]]$name
	print(paste("Downloading column",cur_table_column_name,"from table",cur_table_id,sep=' '))
	#get the column 
	synDownloadTableColumns(sq,columns=list(cur_table_column_name))
	}	
        }	
}
print("Downloaded all tables ")
