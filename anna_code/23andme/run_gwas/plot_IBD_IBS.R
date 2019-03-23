rm(list=ls())
library(ggplot2)
library(reshape2)
library(gplots)
data=read.table("plink.genome",header=TRUE)
subset=subset(data,select=c("FID1","FID2","PI_HAT"))
subset=na.omit(subset)
grouped=acast(subset,FID1~FID2)
heatmap.2(as.matrix(grouped),
          Rowv=FALSE,
          Colv=FALSE,
          dendrogram="none",
          labRow="",
          labCol="",
          density.info = "none",
          trace="none",
          scale="none")