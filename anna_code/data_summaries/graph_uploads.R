library(data.table) 
library(ggplot2) 

#fname<-"/srv/gsfs0/projects/ashley/common/myheart/results/uploads_by_date_and_version.tsv"
#data<-as.data.frame(read.table(fname,header=T,sep="\t"))
#png(filename="uploads_by_date_and_version.png",width=16,height=4,units="in",res=1000)
#ggplot(data, aes(factor(Date), Uploads, fill = Version)) +geom_bar(stat="identity",position="stack")+theme(axis.text.x=element_text(angle=-90))
#dev.off() 
#print("PLOTTED UPLOADS") 


#png(filename="uploads_by_date_and_version_one_per_subject.png",width=16,height=4,units="in",res=1000)
#ggplot(data, aes(factor(Date), ActiveUsers, fill = Version)) + geom_bar(stat="identity", position = "stack") + theme(axis.text.x=element_text(angle=-90))
#dev.off() 


fname<-"new_users_by_date.graph"
data<-as.data.frame(read.table(fname,header=T,sep="\t"))
png(filename="number_of_users.png",width=16,height=4,units="in",res=1000)
ggplot(data, aes(factor(Date), Count, fill = Category)) +geom_bar(stat="identity",position="stack")+theme(axis.text.x=element_text(angle=-90))
dev.off() 
print("PLOTTED UPLOADS") 
