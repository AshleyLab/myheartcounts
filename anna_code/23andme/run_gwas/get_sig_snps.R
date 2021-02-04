rm(list=ls())
library(qqman)
args <- commandArgs(TRUE)
fname=args[1]
thresh=args[2]
data=read.table(fname,header=TRUE,sep='\t',stringsAsFactors=FALSE)
names(data)=c("CHR","BP","SNP","REF","ALT","TEST","OBS_CT","BETA","SE","T_STAT","P")
data=data[data$TEST=="ADD",]
data=na.omit(data) 
data$P[data$P==0]=1e-100
#we want to ignore any SNPs on chromosome 0 -- these are unplaced 
data=data[data$CHR!="0",]
fieldname=strsplit(fname,'/')[[1]][2]
data$FIELD=fieldname

#get the significant SNPs 
sig_subset=data[data$P<as.numeric(thresh),]
write.table(sig_subset,file=paste(fieldname,"significant.csv",sep='.'),row.names = FALSE,col.names = TRUE,sep='\t',quote=FALSE)
