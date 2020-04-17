rm(list=ls())
library(ggplot2)
source("~/helpers.R")
fnames=dir() 
for (fname in fnames){
  if (endsWith(fname,'.tsv')){
print(fname)
data=read.table(fname,header=TRUE,sep='\t')
data$Date=as.Date(data$Date)
data=data[order(data$Date),]
p1=ggplot(data=data,
          aes(x=data$Date,
              y=data$Uploads))+
  geom_bar(stat='identity')+
  xlab("Date")+
  ylab("Uploads")+
  ggtitle(fname)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
p2=ggplot(data=data,
          aes(x=data$Date,
              y=data$Subjects))+
  geom_bar(stat='identity')+
  xlab("Date")+
  ylab("Subjects")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
p3=ggplot(data=data,
          aes(x=data$Date,
              y=data$NewSubjects))+
  geom_bar(stat='identity')+
  xlab("Date")+
  ylab("New Subjects")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
p4=ggplot(data=data,
          aes(x=data$Date,
              y=data$MeanUploadsPerSubjectPerDay))+
  geom_bar(stat='identity')+
  xlab("Date")+
  ylab("Mean Uploads per Subject per Day")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
png(paste(fname,'png',sep='.'),heigh=8,width = 4,units='in',res=120)
multiplot(p1,p2,p3,p4,cols=1)
dev.off() 
}
}