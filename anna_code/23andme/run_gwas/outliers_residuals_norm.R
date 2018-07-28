rm(list=ls())
library(ggplot2)
library(preprocessCore)
library(matrixStats)

data=read.table("../23andme.phenotype",header=TRUE,na.strings=c(""," ","NA"),sep='\t')
#subset to continuous phenotypes 
data=subset(data,select=c('FID','IID',scan("fields.continuous", character(), quote = "")))
data[data==-1000]=NA

#remove any outliers more than 3 st dev away from mean 
d_mean=colMeans(data[,3:ncol(data)],na.rm=TRUE)
d_sd=colSds(as.matrix(data[,3:ncol(data)]),na.rm=TRUE )
upper_bound=d_mean+3*d_sd
lower_bound=d_mean-3*d_sd 
for(col in seq(3,ncol(data)))
{
  cur_upper_bound=upper_bound[col-2]
  cur_lower_bound=lower_bound[col-2]
  to_truncate_upper=which(data[,col]>cur_upper_bound)
  data[to_truncate_upper,col]=cur_upper_bound 
  to_truncate_lower=which(data[,col]<cur_lower_bound) 
  data[to_truncate_lower,col]=cur_lower_bound
}
##get residuals
covar=data.frame(read.table('covariates.txt',header=TRUE,sep='\t'))
covar[covar==-1000]=NA
covar=covar[order(covar$FID),]
data=data[order(data$FID),]
covar$Sex=factor(covar$Sex)
residuals_continuous=matrix(nrow=nrow(data),ncol=ncol(data))

for(col in seq(3,ncol(data)))
{
covar$Y=data[,col]
residuals=as.vector(residuals(lm(Y ~ Sex
                                                +Age
                                                +PC1
                                                +PC2
                                                +PC3
                                                +PC4
                                                +PC5
                                 ,data=covar,na.action=na.exclude),na.action=na.exclude))
residuals_continuous[,col]=residuals
}
residuals_continuous=as.data.frame(residuals_continuous)
residuals_continuous[,1]=data[,1]
residuals_continuous[,2]=data[,2]
names(residuals_continuous)=names(data)

#quantile normalize the residuals 
for(col in seq(3,ncol(residuals_continuous)))
{
residuals_continuous[,col]=normalize.quantiles(as.matrix(residuals_continuous[,col]))
}
residuals_continuous[is.na(residuals_continuous)]=-1000
write.table(residuals_continuous,file="continuous.phenotypes.formatted.tsv",sep='\t',quote=FALSE,row.names=FALSE,col.names=TRUE)
