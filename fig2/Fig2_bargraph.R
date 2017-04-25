library(ggplot2)
library(reshape2)
load("object_merged_k")
s=subset(merged_k,select=c("clusters","satisfiedwith_life"))
s=s[which(s$clusters %in% c(2,4,5,6)),]
s=na.omit(s)
s$clusters=factor(s$clusters,levels=c(5,2,4,6))
p3 <- ggplot(s, aes(clusters, satisfiedwith_life))+
    geom_boxplot(position="dodge",outlier.colour="black",notch=TRUE)+
    stat_summary(fun.y = mean, geom="point",colour="darkred", size=3) 
browser() 
#boxplot(satisfiedwith_life~clusters,data=s, main="Life Satisfaction",style="quantile",
#        xlab="", ylab="Satisfied with Life (1-10)",names=c("Inactive","Drivers","Active","Week. War.")) 
#means <- 	c(6.93,	7.12	,7.45,8)

points(means,col="red",pch=18)
browser()
s=subset(merged_k,select=c("clusters","heart_disease","jointProblem"))
s=s[which(s$clusters %in% c(2,4,5,6)),]
s=na.omit(s)
browser() 
#s=melt(s,id="clusters")
p=ggplot(data=s,
         aes(x=clusters, y=, group=clusters,fill=clusters)) + 
  geom_bar(position="dodge")+
  theme_bw(20)+
  xlab("Medical Condition")+
  ylab("% with Condition")+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

