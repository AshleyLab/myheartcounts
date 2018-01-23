library(ggplot2)
library(data.table)
data=data.frame(read.table("phone_tally.txt",sep='\t',header=FALSE,stringsAsFactors = FALSE))


pie(data$V2, labels = data$V1, main="Phone versions in MHC")