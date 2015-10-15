

library(ggplot2)
library(data.table)
library(reshape2)


data=data.frame(read.table("AGGREGATE_CONFIDENCE.TSV",header=TRUE,sep='\t'))
data=melt(data,id.vars="State")
p=ggplot(data, aes(State, value)) +   
  geom_bar(aes(fill = variable),  stat="identity")+ ylab("Number of Entries")+labs(title="Confidence value distributions by activity state, raw counts")+scale_fill_discrete(guide = guide_legend(title = "Confidence"))+theme_bw(20) 
browser() 
data=data.frame(read.table("AGGREGATE_CONFIDENCE_NORMALIZED.TSV",header=TRUE,sep='\t'))
data=melt(data,id.vars="State")
p=ggplot(data, aes(State, value)) +   
  geom_bar(aes(fill = variable),  stat="identity")+ ylab("Fraction of Entries")+scale_fill_discrete(guide = guide_legend(title = "Confidence"))+labs(title="Confidence distribution by activity state, normalized values")+theme_bw(20) 
browser() 

data=data.frame(read.table("AGGREGATE_CYCLING_TRANSITIONS.TSV",header=TRUE,sep='\t'))
ggplot(data, aes(State, Count)) +   
  geom_bar(stat="identity")+ ylab("Number of Entries")+labs(title="Observed Counts for States Adjacent to Cycling State")+theme_bw() 

