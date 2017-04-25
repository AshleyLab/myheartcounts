library(data.table)
library(ggplot2)
library(NMF)
observed=data.frame(read.table("observed_transitions.csv",header=T,row.names = 1,sep='\t'))
aheatmap(observed, 
         Rowv=NA,
         Colv=NA,
         main="Observed State Transition Probabilities") 
browser() 

observed=data.frame(read.table("observed_minus_expected.csv",header=T,row.names = 1,sep='\t'))
aheatmap(observed, 
         Rowv=NA,
         Colv=NA,
         main="Observed - Expected Transition Probabilities") 