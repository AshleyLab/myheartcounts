rm(list=ls())
library(qqman)
args <- commandArgs(TRUE)
fname=args[1]
data=read.table(fname,header=TRUE,stringsAsFactors=FALSE)
names(data)=c("CHR","SNP","BP","A1","TEST","NMISS","OR","STAT","P")
data=data[data$TEST=="ADD",]
data$P[data$P==0]=1e-100
data=data[data$CHR!="0",]

data$CHR[data$CHR=="X"]=23
data$CHR[data$CHR=="Y"]=24
data$CHR[data$CHR=="MT"]=26
data$CHR=as.numeric(data$CHR)

fieldname=strsplit(fname,'/')[[1]][2]
data$FIELD=fieldname
#remove all the NA's
data=na.omit(data)

manh_name=paste(fname,'.manh.png',sep='')
qq_name=paste(fname,'.qq.png',sep='')
png(manh_name)
manhattan(data,main=fieldname)
dev.off()
png(qq_name)
qq(data$P,main=fieldname)
dev.off()
#get the significant SNPs 
sig_subset=data[data$P<5e-6,]
write.table(sig_subset,file=paste(fieldname,"significant.csv",sep='.'),row.names = FALSE,col.names = TRUE,sep='\t',quote=FALSE)
