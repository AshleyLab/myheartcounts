heart.age <- read.table("cardiovascular-2-APHHeartAge-7259AC18-D711-47A6-ADBD-6CFCECDED1DF-v1.tsv",header=T,as.is=T,sep="\t")

is.duplicated <- function(x) {duplicated(x) | duplicated(x, fromLast=T)}

dim(heart.age)
length(unique(heart.age$healthCode))
table(table(heart.age$healthCode))
pk <- with(heart.age, paste(healthCode, heartAgeDataAge, heartAgeDataGender, sep = "-")

is.dup1 <- is.duplicated(heart.age$healthCode)
is.dup2 <- is.duplicated(pk)

strange.healthcodes <- heart.age[is.dup1 & !is.dup2 ,"healthCode"]
strange.healthcodes <- heart.age[heart.age$healthCode %in% strange.healthcodes, ]

