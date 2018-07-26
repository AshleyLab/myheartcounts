library(NMF)
library(data.table)
library(reshape2)
library(ggplot2)
library("RColorBrewer")
source('helpers.R')

pal="Dark2"
cour <- brewer.pal(6, pal)
data=data.frame(read.table("AGGREGATE_CONFIDENCE.TSV",header=TRUE,sep='\t'))
data=melt(data,id.vars="State")
names(data)=c("State","Confidence","Value")
p1=ggplot(data, aes(State, Value,fill=Confidence)) +   
  geom_bar(stat="identity")+
  ylab("Number of Entries\n")+
  xlab("\nState")+
  scale_x_discrete(labels=c("Auto.","Stat.","Unkn.","Walk.","Run.","Cyc.")) +
  ggtitle('C')+
  theme_bw(30)+
  scale_fill_brewer(palette="Purples")+
  theme(plot.title=element_text(hjust=0))

data=data.frame(read.table("AGGREGATE_CONFIDENCE_NORMALIZED.TSV",header=TRUE,sep='\t'))
data=melt(data,id.vars="State")
names(data)=c("State","Confidence","Value")
p2=ggplot(data, aes(State, Value,fill=Confidence)) +   
  geom_bar(stat="identity")+ 
  ylab("Fraction of Entries\n")+
  xlab("\nState")+
  ggtitle("D")+
  theme_bw(30)+
  scale_x_discrete(labels=c("Auto.","Stat.","Unkn.","Walk.","Run.","Cyc.")) +
  scale_fill_brewer(palette="Purples")+
  theme(plot.title=element_text(hjust=0))


observed=data.frame(read.table("observed_transitions.csv",header=T,sep='\t'))
observed=melt(observed,id="State1")
names(observed)=c("State1","variable","Probability")
observed$State1=factor(observed$State1,levels=c("automotive","stationary","unknown","walking","running","cycling"))
observed$variable=factor(observed$variable,levels=c("automotive","stationary","unknown","walking","running","cycling"))
p3 <- ggplot(observed, aes(y=variable,x=State1,fill=Probability))+
  geom_tile(aes(fill=Probability)) + 
  scale_fill_gradient(low="white", high="darkblue") + 
  xlab("\nStarting State") + 
  ylab("Ending State\n")+
  theme_bw(30)+
  ggtitle("A)")+
  scale_x_discrete(labels=c("Auto.","Stat.","Unkn.","Walk.","Run.","Cyc.")) +
  theme(plot.title=element_text(hjust=0))

observed=data.frame(read.table("observed_minus_expected.csv",header=T,sep='\t'))
observed=melt(observed,id="State1")
names(observed)=c("State1","variable","Probability")
observed$State1=factor(observed$State1,levels=c("automotive","stationary","unknown","walking","running","cycling"))
observed$variable=factor(observed$variable,levels=c("automotive","stationary","unknown","walking","running","cycling"))
p4 <- ggplot(observed, aes(y=variable,x=State1,fill=Probability))+
  geom_tile(aes(fill=Probability)) + 
  scale_fill_gradient(low="white", high="darkblue") + 
  xlab("\nStarting State") + 
  ylab("Ending State\n")+
  theme_bw(30)+
  ggtitle("B)")+
  scale_x_discrete(labels=c("Auto.","Stat.","Unkn.","Walk.","Run.","Cyc.")) +
  theme(plot.title=element_text(hjust=0))

# More complex

data=data.frame(read.table("alldays",header=F))
browser() 
p5 <- ggplot(data, aes(x=V1))+
  geom_histogram() +
  xlab("\nDays with Activity Data")+
  ylab("Number of Subjects\n")+
  xlim(c(0,75))+
  theme_bw(30)+
  ggtitle("e")+
  theme(plot.title=element_text(hjust=0))

hours=data.frame(read.table("allhours",header=F))
p6 <- ggplot(hours, aes(x=as.numeric(V1)),bindwidth=1)+
  geom_histogram()+
  xlab("\nHours/Day with Activity Data")+
  ylab("Number of Entries\n")+
  theme_bw(30)+
  xlim(c(0,24))+
  stat_bin(binwidth=1)+
  ggtitle("f")+
  theme(plot.title=element_text(hjust=0))


multiplot(p1,p3,p5,p2,p4,p6,cols=2) 