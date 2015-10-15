library(tm)
library(data.table)
national_file<-"ssa_national_summary.txt" 
national_stats<-as.data.frame(read.table(national_file,header=TRUE,row.names=1,stringsAsFactors=FALSE))
national_stats$name<-row.names(national_stats)
results<-as.data.frame(read.table("results.clean.tsv",header=TRUE,stringsAsFactors=FALSE,sep="\t"))
merged<-merge(results,national_stats,by="name",all.x=TRUE)

#WRITE TO OUTPUT FILE 
write.table(merged,file="merged.tsv")
