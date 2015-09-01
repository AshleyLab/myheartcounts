library(tm)
library(data.table)
#FILE WITH NATIONAL SUMMARY DATA 
national_file<-"ssa_national_summary.txt" 

#GET THE DIRECTORY TO READ PDF FILES FROM AS A COMMAND LINE ARGUMENT 
args <- commandArgs(trailingOnly = TRUE)
#if (length(args) < 1)
#{
#stop("Please pass directory of pdf files as an argument")
#}
#pdf_directory<-args[1]
pdf_directory<-"/home/anna/scg3/myheartcounts/anna_code/pdf_to_text"

#ITERATE THROUGH PDF FILES AND EXTRACT THE NAME AND EMAIL FIELDS 
files <- list.files(path=pdf_directory, pattern="*.pdf", full.names=T, recursive=FALSE)
tt <- readPDF(engine="xpdf")
#STORE IN DATA FRAME, APPEND NEW ENTRY AT EACH ITERATION 
personal_info<-data.frame(name=character(),email=character(),stringsAsFactors=FALSE)
nfiles<-length(files)
for(i in 1:length(files))
{
    print(paste(i," of ",nfiles))
    fname<-files[i]
    rr <- tt(elem=list(uri=fname),language="en",id="id1")
    browser() 
    name_field<-"Name of Adult Participant"
    email_field<-"Email"
    
    #GET THE NAME 
    name_index<-which(rr$content %in% name_field)
    name_index<-name_index -1 
    #SPLIT ON SPACE TO SELECT ONLY THE FIRST NAME 
    name<-unlist(strsplit(rr$content[name_index],"[ ]"))
    name<-name[1] 

    #GET THE EMAIL 
    name_index<-name_index+2
    email_index<-which(rr$content %in% email_field)
    email_index<-email_index-1 
    email=paste(rr$content[name_index:email_index],collapse="")

    #STORE THE DATA 
    personal_info<-rbind(personal_info,data.frame(name,email))    
}
browser() 
rownames(personal_info)<-personal_info$name 
#MERGE WITH NATIONAL STATISTICS ABOUT NAME AGE AND SEX
national_stats<-as.data.frame(read.table(national_file,header=TRUE,row.names=1,stringsAsFactors=FALSE))
merged<-merge(personal_info,national_stats,by="row.names",all.x=TRUE)

#WRITE TO OUTPUT FILE 
write.table(merged,file="name_to_age_prediction.tsv")
