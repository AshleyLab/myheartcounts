### PREAMBLE ######################################################################################

require(RSQLite)
require(parallel)
require(synapseClient)

data.path <- "/home/common/myhealth/data/"
cache.path <- "/home/common/myhealth/data/synapseCache"

synapseCacheDir(cache.path) 
synapseLogin()

### DATA ##########################################################################################

### survey data

sync.survey <- function() {
    # query your project for all of the tables
    projectId <- "syn3270436"
    q <- synQuery(paste("SELECT id, name FROM table WHERE parentId=='", projectId, "'", sep=""))

    # download survey function
    download.survey <- function(i,q) {
        cat(paste0("* DOWNLOAD TABLE: ", q[i,"table.name"],"\n"))
        sq <- synTableQuery(paste('SELECT * FROM ', q[i,"table.id"]), filePath = paste0(data.path,"/tables/",q[i,'table.name'],".csv"))
        }

    # download all surveys
    sq.all <- mclapply(as.list(1:nrow(q)), download.survey, q, mc.cores=5)
    }

sync.survey()

### blob / accelerometer data

sync.blob <- function(x) {
    # check which columns are filehandle function
    is.filehandle.col <- function(k,sc) {
        if(sc[[k]]@columnType=="FILEHANDLEID"){
            return(sc[[k]]@name)
            } 
        else{
            return(NULL)
            }
        }

    for (j in c('syn3458480','syn3420486')) {
        cat(paste0("* DOWNLOAD TABLE: ", j,"\n"))

        # query table for column annotation
        #tq <- synTableQuery(paste('SELECT * FROM ', j, ' limit 2'))
        tq <- synTableQuery(paste('SELECT * FROM ', j), filePath = file.path(tempdir(), paste0(j,".csv")))

        # get column data from a particular survey
        sc <- synapseClient:::synGetColumns(tq@schema)

        # check which columns are filehandles
        theseCols <- sapply(as.list(1:length(sc)), is.filehandle.col,sc)
        theseCols <- unlist(theseCols)

        # download 
        for (col in theseCols) {
            cat(paste0("* DOWNLOAD BLOB: ", col,"\n"))
            theseFiles[[col]] <-  mclapply(as.list(rownames(tq@values)), function(rn,col,tq) {tryCatch(synDownloadTableFile(tq, rn, col), error=function(e) NA)}, col,tq,mc.cores=20)
            }

        }
    }

#sync.blob()

