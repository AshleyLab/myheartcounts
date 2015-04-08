### PREAMBLE ######################################################################################

require(RSQLite)
require(parallel)
require(synapseClient)
require(jsonlite)

data.path <- "/home/common/myheart/data/"
cache.path <- "/home/common/myheart/data/synapseCache"

synapseCacheDir(cache.path) 
synapseLogin()

sixmin.file <- "/home/common/myheart/data/examples/pedometer_fitness.walk.items-0feb2fa5-6226-42e5-87c6-d9729b91c0a68733636005062759633.tmp"

# read 6min walk
read_sixmin <- function(sixmin.file) {
    sixmin.data <- fromJSON(sixmin.file)
    }

# summarize 6min walk
summarize_sixmin <- function(sixmin.data) {
    sixmin.data$duration <- as.numeric(difftime(strptime(sixmin.data$startDate,"%Y-%m-%dT%H:%M:%S%z"), strptime(sixmin.data$endDate, "%Y-%m-%dT%H:%M:%S%z"), units="mins"))
    colSums(sixmin.data[,c(1,2,5,6,7)])
    c(duration=duration, rowSums(sixmin.data[,c(1,2,5,6)]))
    }

