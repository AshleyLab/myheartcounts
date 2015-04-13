### PREAMBLE ######################################################################################

require(ggplot2)
require(RSQLite)
require(parallel)
require(synapseClient)
require(jsonlite)
require(data.table)

data.path <- "/home/common/myheart/data/"
cache.path <- "/home/common/myheart/data/synapseCache"
sixmin.meta.file <- "/home/common/myheart/data/tables/cardiovascular-6MinuteWalkTest-v2.tsv"
projectId <- "syn3270436"
tableId <- "syn3458480"

synapseCacheDir(cache.path) 
synapseLogin()
pq <- synQuery(paste("SELECT id, name FROM table WHERE parentId=='", projectId, "'", sep=""))

#sixmin.file <- "/home/common/myheart/data/examples/pedometer_fitness.walk.items-0feb2fa5-6226-42e5-87c6-d9729b91c0a68733636005062759633.tmp"

### FUNCTIONS #####################################################################################

# read 6min walk
read_yml <- function(x) {
    y <- fromJSON(x)
    }

# summarize 6min walk
summarize_ped <- function(sixmin.blob.file) {
    sixmin.blob.data <- read_yml(sixmin.blob.file)
    sixmin.blob.data$distance <- round(sixmin.blob.data$distance,2)
    n.rows <- nrow(sixmin.blob.data)
    #duration1 <- round(max(as.numeric(difftime(strptime(sixmin.blob.data$endDate,"%Y-%m-%dT%H:%M:%S%z"), strptime(sixmin.blob.data$startDate, "%Y-%m-%dT%H:%M:%S%z"), units="mins"))),2)
    duration1 <- round((as.numeric(difftime(strptime(sixmin.blob.data[n.rows,'endDate'],"%Y-%m-%dT%H:%M:%S%z"), strptime(sixmin.blob.data[1,'startDate'], "%Y-%m-%dT%H:%M:%S%z"), units="mins"))),2)
    duration2 <- round(as.numeric(difftime(strptime(sixmin.blob.data[n.rows,"endDate"],"%Y-%m-%dT%H:%M:%S%z"), strptime(sixmin.blob.data[1,"endDate"],"%Y-%m-%dT%H:%M:%S%z"),units="mins")),2)
    #mean.interval <- mean(as.numeric(difftime(strptime(sixmin.blob.data[2:(n.rows),"endDate"],"%Y-%m-%dT%H:%M:%S%z"), strptime(sixmin.blob.data[1:(n.rows-1),"endDate"],"%Y-%m-%dT%H:%M:%S%z"),units="secs")))
    
    unlist(c(ped.blob.file=sixmin.blob.file,duration1=duration1, duration2=duration2, sixmin.blob.data[n.rows,c(1,2,5,6)]))
    }

# clean 6min
filter_ped <- function(ped.blob.data) {
    # duration > 5.5min
    # filter for odd values
    n.rows <- nrow(ped.blob.data)
    cat(paste0("* unfiltered        n: ", n.rows, "\n"))
    ped.blob.data.filter <- with(ped.blob.data, ped.blob.data[!is.na(duration1) & !is.na(duration2) & !is.na(distance) & !is.na(numberOfSteps),] )
    is.filter  <- !with(ped.blob.data, !is.na(duration1) & !is.na(duration2) & !is.na(distance) & !is.na(numberOfSteps) )
    cat(paste0("* nas               n: ", n.rows - nrow(ped.blob.data.filter), "\n"))
    n.rows <- nrow(ped.blob.data.filter)
    ped.blob.data.filter <- ped.blob.data.filter[ped.blob.data.filter$duration1>0,]
    is.filter <- is.filter | !ped.blob.data$duration1>0
    cat(paste0("* negative duration1 n: ", n.rows - nrow(ped.blob.data.filter), "\n"))
    n.rows <- nrow(ped.blob.data.filter)
    ped.blob.data.filter <- ped.blob.data.filter[ped.blob.data.filter$duration2>5.5 & ped.blob.data.filter$duration2<6.5,]
    is.filter <- is.filter | !(ped.blob.data$duration2>5.5 & ped.blob.data$duration2<6.5)
    cat(paste0("* duration2 i.e. endn-startn <5.5&>6.5 n: ", n.rows - nrow(ped.blob.data.filter), "\n"))
    n.rows <- nrow(ped.blob.data.filter)
    ped.blob.data.filter <- ped.blob.data.filter[ped.blob.data.filter$duration1>5.5 & ped.blob.data.filter$duration1<6.5,]
    is.filter <- is.filter | !(ped.blob.data$duration1>5.5 & ped.blob.data$duration1<6.5)
    cat(paste0("* duration1 endn-end1 <5.5&>6.5 n: ", n.rows - nrow(ped.blob.data.filter), "\n"))
    n.rows <- nrow(ped.blob.data.filter)
    ped.blob.data.filter <- ped.blob.data.filter[ped.blob.data.filter$numberOfSteps>20 & ped.blob.data.filter$distance>20,]
    is.filter <- is.filter | !(ped.blob.data$numberOfSteps>20 & ped.blob.data$distance>20)
    cat(paste0("* steps&dist >20     n: ", n.rows - nrow(ped.blob.data.filter), "\n"))
    n.rows <- nrow(ped.blob.data.filter)
    #ped.blob.data.filter <- by(ped.blob.data.filter, ped.blob.data.filter$healthCode, function(x){ x[which.max(x$distance),] },simplify=T)
    which.unique <- by(ped.blob.data.filter, ped.blob.data.filter$healthCode, function(x){ rownames(x[which.max(x$distance),]) },simplify=T)
    is.filter <- is.filter | !rownames(ped.blob.data) %in% which.unique
    ped.blob.data.filter <- ped.blob.data.filter[which.unique,]
    #ped.blob.data.filter <- do.call(rbind, ped.blob.data.filter)
    cat(paste0("* duplicates        n: ", n.rows - nrow(ped.blob.data.filter), "\n"))
    cat(paste0("* filtered          n: ", nrow(ped.blob.data.filter),"\n"))
    return(is.filter)

    }


summarize_hr <- function(x) {
    x.data <- read_yml(x)
    if (!is.null(x.data)){
        n.rows <- nrow(x.data)
        hr.duration1 <- round((as.numeric(difftime(strptime(x.data[n.rows,'endDate'],"%Y-%m-%dT%H:%M:%S%z"), strptime(x.data[1,'startDate'], "%Y-%m-%dT%H:%M:%S%z"), units="mins"))),2)
        hr.mean <- round(mean(x.data$value,na.rm=T),2)
        hr.sd   <- round(sd(x.data$value,na.rm=T),2)
        hr.device <- x.data[1,"source"]
        hr.units <- x.data[1,"unit"]
        return(c(x,T,hr.duration1,hr.device, hr.mean,hr.sd, hr.units))
    }else {
        return(c(NA,F,NA,NA,NA,NA,NA))
        }
    }

summarize_acc <- function(x) {
    x.data <- read_yml(x)
    browser()
    if (!is.null(x.data)){
        n.rows <- nrow(x.data)
        acc.duration1 <- round((as.numeric(difftime(strptime(x.data[n.rows,'endDate'],"%Y-%m-%dT%H:%M:%S%z"), strptime(x.data[1,'startDate'], "%Y-%m-%dT%H:%M:%S%z"), units="mins"))),2)
        acc.mean <- round(mean(x.data$value,na.rm=T),2)
        acc.sd   <- round(sd(x.data$value,na.rm=T),2)
        acc.device <- x.data[1,"source"]
        acc.units <- x.data[1,"unit"]
        return(c(x,T,hr.duration1,hr.device, hr.mean,hr.sd, hr.units))
    }else {
        return(c(NA,F,NA,NA,NA,NA,NA))
        }
    }


is.duplicated <- function(x) {duplicated(x) | duplicated(x,fromLast=T)}
### SIXMIN ########################################################################################

# meta
sixmin.meta.data <- read.table(sixmin.file, header=T,as.is=T,sep="\t")

# ped file
ped.cache.dir  <- paste0(cache.path, "/", as.numeric(substr(sixmin.meta.data$pedometer_fitness.walk.items, 5,8)),"/", as.numeric(sixmin.meta.data$pedometer_fitness.walk.items))
ped.blob.file  <- paste0(ped.cache.dir, "/", lapply(as.list(ped.cache.dir), dir))

# accelerometer file
acc.walk.cache.dir  <- paste0(cache.path, "/", as.numeric(substr(sixmin.meta.data$accel_fitness_walk.json.items, 5,8)),"/", as.numeric(sixmin.meta.data$accel_fitness_walk.json.items))
acc.walk.blob.file <- paste0(acc.walk.cache.dir, "/", lapply(as.list(acc.walk.cache.dir), dir))
acc.rest.cache.dir  <- paste0(cache.path, "/", as.numeric(substr(sixmin.meta.data$accel_fitness_rest.json.items, 5,8)),"/", as.numeric(sixmin.meta.data$accel_fitness_rest.json.items))
acc.rest.blob.file  <- paste0(acc.rest.cache.dir, "/", lapply(as.list(acc.rest.cache.dir), dir))

# device motion
motion.walk.cache.dir  <- paste0(cache.path, "/", as.numeric(substr(sixmin.meta.data$deviceMotion_fitness.walk.items, 5,8)),"/", as.numeric(sixmin.meta.data$deviceMotion_fitness.walk.items))
motion.walk.blob.file  <- paste0(motion.walk.cache.dir, "/", lapply(as.list(motion.walk.cache.dir), dir))
motion.rest.cache.dir  <- paste0(cache.path, "/", as.numeric(substr(sixmin.meta.data$deviceMotion_fitness.rest.items, 5,8)),"/", as.numeric(sixmin.meta.data$deviceMotion_fitness.rest.items))
motion.rest.blob.file  <- paste0(motion.rest.cache.dir, "/", lapply(as.list(motion.rest.cache.dir), dir))


# heart rate
hr.walk.cache.dir  <- paste0(cache.path, "/", as.numeric(substr(sixmin.meta.data$HKQuantityTypeIdentifierHeartRate_fitness.walk.items, 5,8)),"/", as.numeric(sixmin.meta.data$HKQuantityTypeIdentifierHeartRate_fitness.walk.items))
hr.walk.blob.file  <- paste0(hr.walk.cache.dir, "/", lapply(as.list(hr.walk.cache.dir), dir))
hr.rest.cache.dir  <- paste0(cache.path, "/", as.numeric(substr(sixmin.meta.data$HKQuantityTypeIdentifierHeartRate_fitness.rest.items, 5,8)),"/", as.numeric(sixmin.meta.data$HKQuantityTypeIdentifierHeartRate_fitness.rest.items))
hr.rest.blob.file  <- paste0(hr.rest.cache.dir, "/", lapply(as.list(hr.rest.cache.dir), dir))


### PEDOMETER #####################################################################################

run_ped <- function() {
# loop over and summarize
ped.blob.data <- lapply(as.list(ped.blob.file), function(x) {tryCatch(summarize_ped(x),  error=function(e) NA)})
ped.blob.data <- data.frame(do.call(rbind, ped.blob.data))
ped.blob.data[,colnames(ped.blob.data) %in% c("duration1","duration2","floorsAscended","floorsDescended","numberOfSteps","distance")] <- apply(ped.blob.data[,colnames(ped.blob.data) %in% c("duration1","duration2","floorsAscended","floorsDescended","numberOfSteps","distance")], 2, function(x) {round(as.numeric(x),2)})
ped.blob.data$dist.per.step.rate <- ped.blob.data$distance / ped.blob.data$numberOfSteps

ped.blob.data <- data.frame(sixmin.meta.data, ped.blob.data)

# filter
#ped.blob.data.filter <- filter_ped(ped.blob.data)
is.filter.ped <- filter_ped(ped.blob.data)
ped.blob.data$ped.is.filter <- is.filter.ped
ped.blob.data.filter <- ped.blob.data[!is.filter.ped,]
n.attempts <- table(ped.blob.data[is.duplicated(ped.blob.data$healthCode),'healthCode'])

# write
write.table(ped.blob.data, "/home/common/myheart/data/tables/cardiovascular-6MinuteWalkTest-v2_withSteps.tsv", quote=F, row.names=F, sep="\t")
write.table(ped.blob.data.filter, "/home/common/myheart/data/tables/cardiovascular-6MinuteWalkTest-v2_withSteps_filtered.tsv", quote=F, row.names=F, sep="\t")

# plot 
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

return(ped.blob.data)

}
run_ped()
stop()
###  ACCELEROMETER DATA ###########################################################################

run_acc <- function() {
 
test = read_yml(acc.walk.blob.file[1])

acc.walk.blob.data <- lapply(as.list(acc.walk.blob.file), function(x) {tryCatch(summarize_acc(x),  error=function(e) NA)})
acc.walk.blob.data <- data.frame(do.call(rbind, acc.walk.blob.data))
colnames(acc.walk.blob.data) <- c("acc.walk.path","acc.walk.present","acc.walk.duration1","acc.walk.device","acc.walk.mean","acc.walk.sd","acc.walk.units")

acc.rest.blob.data <- lapply(as.list(acc.rest.blob.file), function(x) {tryCatch(summarize_acc(x),  error=function(e) NA)})
acc.rest.blob.data <- data.frame(do.call(rbind, acc.rest.blob.data))
colnames(acc.rest.blob.data) <- c("acc.rest.path","acc.rest.present","acc.rest.duration1","acc.rest.device","acc.rest.mean","acc.rest.sd","acc.rest.units")

}
#run_acc()

###  MOTION DATA $$$$$$$###########################################################################

run_motion <- function() {

test = read_yml(motion.walk.blob.file[1])

motion.walk.blob.data <- lapply(as.list(motion.walk.blob.file), function(x) {tryCatch(summarize_motion(x),  error=function(e) NA)})
motion.walk.blob.data <- data.frame(do.call(rbind, motion.walk.blob.data))
colnames(motion.walk.blob.data) <- c("motion.walk.path","motion.walk.present","motion.walk.duration1","motion.walk.device","motion.walk.mean","motion.walk.sd","motion.walk.units")

motion.rest.blob.data <- lapply(as.list(motion.rest.blob.file), function(x) {tryCatch(summarize_motion(x),  error=function(e) NA)})
motion.rest.blob.data <- data.frame(do.call(rbind, motion.rest.blob.data))
colnames(motion.rest.blob.data) <- c("motion.rest.path","motion.rest.present","motion.rest.duration1","motion.rest.device","motion.rest.mean","motion.rest.sd","motion.rest.units")

}
#run_motion()

### HR DATA #######################################################################################

run_hr <- function() {

hr.walk.blob.data <- lapply(as.list(hr.walk.blob.file), function(x) {tryCatch(summarize_hr(x),  error=function(e) NA)})
hr.walk.blob.data <- data.frame(do.call(rbind, hr.walk.blob.data))
colnames(hr.walk.blob.data) <- c("hr.walk.path","hr.walk.present","hr.walk.duration1","hr.walk.device","hr.walk.mean","hr.walk.sd","hr.walk.units")

hr.rest.blob.data <- lapply(as.list(hr.rest.blob.file), function(x) {tryCatch(summarize_hr(x),  error=function(e) NA)})
hr.rest.blob.data <- data.frame(do.call(rbind, hr.rest.blob.data))
colnames(hr.rest.blob.data) <- c("hr.rest.path","hr.rest.present","hr.rest.duration1","hr.rest.device","hr.rest.mean","hr.rest.sd","hr.rest.units")

}
run_hr()

### WRITE #########################################################################################

# combine
sixmin.meta.data <- data.frame(sixmin.meta.data, ped.blob.data, hr.walk.blob.data,hr.rest.blob.data)

# write.output
write.table(sixmin.blob.data, "/home/common/myheart/data/tables/cardiovascular-6MinuteWalkTest-v2_withSteps.tsv", quote=F, row.names=F, sep="\t")
write.table(sixmin.blob.data.filter, "/home/common/myheart/data/tables/cardiovascular-6MinuteWalkTest-v2_withSteps_filtered.tsv", quote=F, row.names=F, sep="\t")
