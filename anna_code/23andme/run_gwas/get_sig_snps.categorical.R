rm(list=ls())
library(qqman)
args <- commandArgs(TRUE)
fname=args[1]
thresh=args[2]
data=read.table(fname,header=TRUE,stringsAsFactors=FALSE)
names(data)=c("CHR","BP","SNP","REF","ALT","FIRTH","TEST","OBS_CT","OR","SE","T_STAT","P")

data=data[data$TEST=="ADD",]
data=na.omit(data) 
data$P[data$P==0]=1e-100
data=data[data$CHR!="0",]
fieldname=strsplit(fname,'/')[[1]][2]
data$FIELD=fieldname
#get the significant SNPs 
sig_subset=data[data$P<as.numeric(thresh),]
write.table(sig_subset,file=paste(fieldname,"significant.csv",sep='.'),row.names = FALSE,col.names = TRUE,sep='\t',quote=FALSE)
