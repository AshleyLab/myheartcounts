rm(list=ls())
library(data.table) 
path="/home/annashch/myheartcounts/anna_code/breaks/200" 
prefix="breakpoints_200_"
files<-list.files(path=path,pattern=paste(prefix,"*",sep=""),full.names=T,recursive=FALSE)
gotfirst=FALSE 
for(i in 1:length(files))
{
	print(files[i]) 
	load(files[i]) 
	if(gotfirst==FALSE) 
	{
	features_200<-features
	gotfirst=TRUE  
	}
	else
	{
	features_200<-rbind(features_200,features) 
	}	
}
save(features_200,file="full_breakpoints_200") 
