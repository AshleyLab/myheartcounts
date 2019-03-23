rm(list=ls())
batch1=read.table("allele_counts_by_pos.batch1",header=TRUE,sep='\t',row.names = 1)
batch1=subset(batch1,select=c("A","C","G","T"))
batch2=read.table("allele_counts_by_pos.batch2",header=TRUE,sep='\t',row.names = 1)
batch2=subset(batch2,select=c("A","C","G","T"))

#row-normalize batch 1 & batch 2 
batch1=batch1/rowSums(batch1)
batch2=batch2/rowSums(batch2)
deltaA=batch1$A-batch2$A
deltaC=batch1$C-batch2$C 
deltaG=batch1$G-batch2$G
deltaT=batch1$T-batch2$T 
deltas=data.frame(deltaA,deltaC,deltaG,deltaT)
library(reshape2)
m=melt(deltas)

p=ggplot(data=m,aes(value,group=variable,fill=variable))+
  geom_histogram(position='identity',bins=100,alpha=0.5)+
  xlim(c(-.25,0.25))+
  theme_bw(20)+
  xlab("batch1 - batch2 allele frequency")

merged=cbind(batch1,batch2)
names(merged)=c("A.1","C.1","G.1","T.1","A.2","C.2","G.2","T.2")