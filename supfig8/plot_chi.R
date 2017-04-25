library(data.table)
library(ggplot2)
library(reshape2)
data=data.frame(read.table('chisquared.csv',header=T,sep='\t'))
mdf<- melt(data, id="Condition")  # convert to long format
p=ggplot(data=mdf,
         aes(x=Condition, y=value, col=variable,group=variable)) + 
  geom_point(size=5)+
  geom_line()+
  theme_bw(20)+
  xlab("Medical Condition")+
  ylab("Obs.-Exp. Std. Res.")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
  #scale_color_manual(values=c("#FF0000", "#66FF33", "#0000FF","#CC9900","#CC9900","#BDA0CB"))

