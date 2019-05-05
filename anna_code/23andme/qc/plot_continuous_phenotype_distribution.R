rm(list=ls())
library(ggplot2)
data=read.table("continuous.phenotypes.formatted.csv",header=TRUE,sep='\t')

rownames(data)=data$FID
data$FID=NULL 
data$IID=NULL
data[data==-1000]=NA
numfields=ncol(data)
columns=names(data)
for(colindex in seq(1,numfields)){
  curfield=columns[colindex]
  print(curfield)
  fname=paste(curfield,'outliers','residuals','norm','png',sep='.')
  n=length(which(!is.na(data[curfield])))
  png(fname)
  print(ggplot(data)+
    aes(x=data[[curfield]])+
    geom_histogram(bins=30)+
    xlab(curfield)+
    ggtitle(paste(curfield,': n=',n)))
  dev.off() 
  }