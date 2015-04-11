### PREAMBLE ######################################################################################

require(ggplot2)
require(RSQLite)
require(parallel)
require(synapseClient)
require(jsonlite)
require(data.table)

data.path <- "/home/common/myheart/data/"
cache.path <- "/home/common/myheart/data/synapseCache"

synapseCacheDir(cache.path) 
synapseLogin()

#sixmin.file <- "/home/common/myheart/data/examples/pedometer_fitness.walk.items-0feb2fa5-6226-42e5-87c6-d9729b91c0a68733636005062759633.tmp"

# read 6min walk
read_sixmin <- function(sixmin.blob.file) {
    sixmin.blob.data <- fromJSON(sixmin.blob.file)
    }

# summarize 6min walk
summarize_sixmin <- function(sixmin.blob.file) {
    sixmin.blob.data <- read_sixmin(sixmin.blob.file)
    sixmin.blob.data$distance <- round(sixmin.blob.data$distance,2)
    n.rows <- nrow(sixmin.blob.data)
    duration1 <- round(max(as.numeric(difftime(strptime(sixmin.blob.data$endDate,"%Y-%m-%dT%H:%M:%S%z"), strptime(sixmin.blob.data$startDate, "%Y-%m-%dT%H:%M:%S%z"), units="mins"))),2)
    duration2 <- round(as.numeric(difftime(strptime(sixmin.blob.data[n.rows,"endDate"],"%Y-%m-%dT%H:%M:%S%z"), strptime(sixmin.blob.data[1,"endDate"],"%Y-%m-%dT%H:%M:%S%z"),units="mins")),2)
    #mean.interval <- mean(as.numeric(difftime(strptime(sixmin.blob.data[2:(n.rows),"endDate"],"%Y-%m-%dT%H:%M:%S%z"), strptime(sixmin.blob.data[1:(n.rows-1),"endDate"],"%Y-%m-%dT%H:%M:%S%z"),units="secs")))
    
    unlist(c(ped.blob.file=sixmin.blob.file,duration1=duration1, duration2=duration2, sixmin.blob.data[n.rows,c(1,2,5,6)]))
    }

# clean 6min
clean_sixmin <- function() {
    # duration > 5.5min
    }

projectId <- "syn3270436"
pq <- synQuery(paste("SELECT id, name FROM table WHERE parentId=='", projectId, "'", sep=""))
tableId <- "syn3458480"

sixmin.meta.file <- "/home/common/myheart/data/tables/cardiovascular-6MinuteWalkTest-v2.tsv"
sixmin.meta.data <- read.table(sixmin.file, header=T,as.is=T,sep="\t")

ped.cache.dir <-  paste0(cache.path, "/", as.numeric(substr(sixmin.meta.data$pedometer_fitness.walk.items, 5,8)),"/", as.numeric(sixmin.meta.data$pedometer_fitness.walk.items))
sixmin.blob.file <- paste0(ped.cache.dir, "/", lapply(as.list(ped.cache.dir), dir))

sixmin.blob.data <- lapply(as.list(sixmin.blob.file), function(x) {tryCatch(summarize_sixmin(x),  error=function(e) NA)})
sixmin.blob.data <- data.frame(sixmin.meta.data, do.call(rbind, sixmin.blob.data))
sixmin.blob.data[,colnames(sixmin.blob.data) %in% c("duration1","duration2","floorsAscended","floorsDescended","numberOfSteps","distance")] <- apply(sixmin.blob.data[,colnames(sixmin.blob.data) %in% c("duration1","duration2","floorsAscended","floorsDescended","numberOfSteps","distance")], 2, function(x) {round(as.numeric(x),2)})

sixmin.blob.data$dist.per.step.rate <- sixmin.blob.data$distance / sixmin.blob.data$numberOfSteps

# filter for odd values
n.rows <- nrow(sixmin.blob.data)
cat(paste0("* unfiltered        n: ", n.rows, "\n"))
sixmin.blob.data.filter <- with(sixmin.blob.data, sixmin.blob.data[!is.na(duration1) & !is.na(duration2) & !is.na(distance) & !is.na(numberOfSteps),] )
cat(paste0("* nas               n: ", n.rows - nrow(sixmin.blob.data.filter), "\n"))
n.rows <- nrow(sixmin.blob.data.filter)
sixmin.blob.data.filter <- sixmin.blob.data.filter[sixmin.blob.data.filter$duration1>0,]
cat(paste0("* negative duration1 n: ", n.rows - nrow(sixmin.blob.data.filter), "\n"))
n.rows <- nrow(sixmin.blob.data.filter)
sixmin.blob.data.filter <- sixmin.blob.data.filter[sixmin.blob.data.filter$duration2>5.5 & sixmin.blob.data.filter$duration2<6.5,]
cat(paste0("* duration2 i.e. endn-startn <5.5&>6.5 n: ", n.rows - nrow(sixmin.blob.data.filter), "\n"))
n.rows <- nrow(sixmin.blob.data.filter)
sixmin.blob.data.filter <- sixmin.blob.data.filter[sixmin.blob.data.filter$duration1>5.5 & sixmin.blob.data.filter$duration1<6.5,]
cat(paste0("* duration1 endn-end1 <5.5&>6.5 n: ", n.rows - nrow(sixmin.blob.data.filter), "\n"))
n.rows <- nrow(sixmin.blob.data.filter)
sixmin.blob.data.filter <- sixmin.blob.data.filter[sixmin.blob.data.filter$numberOfSteps>20 & sixmin.blob.data.filter$distance>20,]
cat(paste0("* steps&dist >20     n: ", n.rows - nrow(sixmin.blob.data.filter), "\n"))
n.rows <- nrow(sixmin.blob.data.filter)
sixmin.blob.data.filter <- by(sixmin.blob.data.filter, sixmin.blob.data.filter$healthCode, function(x){ x[which.max(x$distance),] },simplify=T)
sixmin.blob.data.filter <- do.call(rbind, sixmin.blob.data.filter)
cat(paste0("* duplicates        n: ", n.rows - nrow(sixmin.blob.data.filter), "\n"))
cat(paste0("* filtered          n: ", nrow(sixmin.blob.data.filter),"\n"))
is.duplicated <- function(x) {duplicated(x) | duplicated(x,fromLast=T)}
n.attempts <- table(sixmin.blob.data[is.duplicated(sixmin.blob.data$healthCode),'healthCode'])

pdf("sixmin_distribution.pdf")
for (col in  c("duration1","duration2","floorsAscended","floorsDescended","numberOfSteps","distance","dist.per.step.rate")) {
#hist(as.numeric(sixmin.blob.data[,i]),main=colnames(sixmin.blob.data)[i], xlab=colnames(sixmin.blob.data)[i])
p0 <- ggplot(data=sixmin.blob.data.filter, aes(sixmin.blob.data.filter[,col])) + geom_histogram() + xlab(col) + theme_bw(20) 
plot(p0)
}
#p1 <- ggplot(data=sixmin.blob.data[is.duplicated(sixmin.blob.data$healthCode),], aes(factor(healthCode))) + geom_bar() + xlab("Health Code") + theme_bw(20)
p1 <- ggplot(data=as.data.frame(n.attempts), aes(x=Freq)) + geom_histogram() + xlab("Number of 6min Attempts (>1)") + theme_bw(20)
plot(p1)
dev.off()

write.table(sixmin.blob.data, "/home/common/myheart/data/tables/cardiovascular-6MinuteWalkTest-v2_withSteps.tsv", quote=F, row.names=F)
write.table(sixmin.blob.data.filter, "/home/common/myheart/data/tables/cardiovascular-6MinuteWalkTest-v2_withSteps_filtered.tsv", quote=F, row.names=F)



