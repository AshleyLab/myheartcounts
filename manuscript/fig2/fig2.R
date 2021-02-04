rm(list=ls())
library(ggplot2)
library(reshape2)
library(data.table)
library(RColorBrewer)

source('helpers.R')
pal="Dark2"
cour <- brewer.pal(6, pal)
indices=c(1,3,5,6)
cour=cour[indices]
#Fig2a
#normalize! 
#load("full_breakpoints_2")
#data=subset(features_2,select=c("stationary_day","stationary_end","changes_day","changes_end"))
#data$cur_subject=NULL 
#data$changes_day=data$changes_day/max(data$changes_day)
#data$changes_end=data$changes_end/max(data$changes_end) 
#fit=kmeans(data,6,nstart=10)
#data$Cluster=factor(fit$cluster)
#data$changes_day=features_100$changes_day 
#data$changes_end=features_100$changes_end1
load("BREAKS")
p1<-ggplot(data,aes(stationary_day,stationary_end,colour = Cluster)) + 
  geom_point(alpha=1/2) + 
  xlab("\nWeekday")+
  ylab("Weekend\n")+
  ggtitle("a")+
  theme_bw(30)+theme(legend.position = c(.1, 0.75))+
  theme(plot.title=element_text(hjust=0))+
  scale_colour_brewer(palette=pal)
p1
#Fig2b
data=data.frame(read.table('illness.csv',header=T,sep='\t'))
names(data)=c("Condition","Drivers","Weekend\nWarriors","Inactive","Active")
mdf<- melt(data, id="Condition")  # convert to long format
mdf$variable=factor(mdf$variable,levels=c("Active","Weekend\nWarriors","Inactive","Drivers"))
names(mdf)=c("Condition","Group","value")
browser() 
p2=ggplot(data=mdf,
         aes(x=Condition, y=value,fill=Group,group=Group)) + 
  geom_bar(stat="identity",position="dodge")+
  ylim(c(0,30))+
  ylab("Percent with Condition\n")+
  xlab("\nCondition")+
  geom_segment(aes(x=1.85, y=22.5, xend=1.85, yend=23)) +
  geom_segment(aes(x=1.85, y=23, xend=2.10, yend=23)) +
  geom_segment(aes(x=2.10, y=23, xend=2.10, yend=22.5)) +
  annotate("text", x=2.0, y=23.5, label="**",size=10) +
  
  geom_segment(aes(x=1.6, y=24.5, xend=1.6, yend=25)) +
  geom_segment(aes(x=1.6, y=25, xend=2.10, yend=25)) +
  geom_segment(aes(x=2.10, y=25, xend=2.10, yend=24.5)) +
  annotate("text", x=2, y=25.5, label="***",size=10) +
  
  geom_segment(aes(x=1.6, y=26.5, xend=1.6, yend=27)) +
  geom_segment(aes(x=1.6, y=27, xend=2.4, yend=27)) +
  geom_segment(aes(x=2.4, y=27, xend=2.4, yend=26.5)) +
  annotate("text", x=2.0, y=27.5, label="**",size=10) +
  
 
  geom_segment(aes(x=0.6, y=17.5, xend=0.6, yend=18)) +
  geom_segment(aes(x=0.6, y=18, xend=1.4, yend=18)) +
  geom_segment(aes(x=1.40, y=18, xend=1.4, yend=17.5)) +
  annotate("text", x=1.0, y=18.5, label="****",size=10) +
  
  geom_segment(aes(x=0.85, y=15.5, xend=0.85, yend=16)) +
  geom_segment(aes(x=0.85, y=16, xend=1.4, yend=16)) +
  geom_segment(aes(x=1.4, y=16, xend=1.4, yend=15.5)) +
  annotate("text", x=1.0, y=16.5, label="*****",size=10) +
  
  geom_segment(aes(x=0.85, y=13.5, xend=0.85, yend=14)) +
  geom_segment(aes(x=0.85, y=14, xend=1.1, yend=14)) +
  geom_segment(aes(x=1.1, y=14, xend=1.1, yend=13.5)) +
  annotate("text", x=1, y=14.5, label="***",size=10) +

  geom_segment(aes(x=1.15, y=13.5, xend=1.15, yend=14)) +
  geom_segment(aes(x=1.15, y=14, xend=1.4, yend=14)) +
  geom_segment(aes(x=1.4, y=14, xend=1.4, yend=13.5)) +
  annotate("text", x=1.25, y=14.5, label="**",size=10) +
  

  theme_bw(30)+
  scale_fill_manual(values = cour)+
  ggtitle("b")+
  theme(legend.position = c(0.2, 0.8))+
  theme(plot.title=element_text(hjust=0))
p2


#Fig2c

load("object_merged_k")
sub=merged_k[which(merged_k$clusters %in% c(2,4,5,6)),]
sub$clusters=factor(sub$clusters,levels=c(5,2,4,6))
sub=subset(sub,select=c("clusters","satisfiedwith_life"))
sub=na.omit(sub)
sub$clusters=as.numeric(sub$clusters)
sub$satisfiedwith_life=as.numeric(sub$satisfiedwith_life)
names(sub) <- c("group", "value")
mydata=sub

# function for computing mean, DS, max and min values
min.mean.sd.max <- function(x) {
  r <- c(min(x), mean(x) - sd(x), mean(x), mean(x) + sd(x), max(x))
  names(r) <- c("ymin", "lower", "middle", "upper", "ymax")
  r
  
}
# ggplot code
p3 <- ggplot(aes(y = value, x = factor(group)), data = mydata)+
  stat_summary(fun.data = min.mean.sd.max, geom = "boxplot",size=2)  +
  ggtitle("c")+
  ylab("Life Satisfaction (1-10)\n")+
  xlab("\nActivity Cluster")+
  scale_x_discrete(labels=c("Inactive","Drivers","Weekend\nWarriors","Active")) +
  ylim(c(6,10))+
  theme_bw(30)+
  theme(plot.title=element_text(hjust=0))
multiplot(p1, p2, p3, cols=3)

