rm(list=ls())
library(ggplot2)
library(reshape2)
library(data.table)
library(RColorBrewer)
library(RSvgDevice)
source('helpers.R')
pal="Set3"
cour <- brewer.pal(10, pal)
indices=c(6,4,5,2)
cour_small=cour[indices]
#Fig2a
data=data.frame(read.table("Activity_states_weekday_weekend_total_10022015.tsv",header=T,sep='\t'))
load("object_merged_k")
merged=merge(data,merged_k,by.x="Subject",by.y="Row.names") 

#load("BREAKS")
#svg(file="Figure2_panelA.svg",onefile=TRUE,width=9)
p1<-ggplot(merged,aes(StationaryWeekday,StationaryWeekend,colour = clusters)) + 
  geom_point(alpha=1/2) + 
  xlab("\nWeekday")+
  ylab("Weekend\n")+
  ggtitle("A")+
  theme_bw(30)+
  theme(legend.position = c(.13, 0.65),
                     legend.background = element_rect(fill=alpha('white', 0.01)))+
  theme(plot.title=element_text(hjust=0))+
  scale_colour_brewer(palette=pal)

#Fig2b
data=data.frame(read.table('illness.csv',header=T,sep='\t'))
names(data)=c("Condition","Drivers","Weekend\nWarriors","Inactive","Active")
mdf<- melt(data, id="Condition")  # convert to long format
mdf$variable=factor(mdf$variable,levels=c("Active","Weekend\nWarriors","Inactive","Drivers"))
names(mdf)=c("Condition","Group","value")
p2=ggplot(data=mdf,
         aes(x=Condition, y=value,fill=Group,group=Group)) + 
  geom_bar(stat="identity",position="dodge")+
  scale_x_discrete(labels=c("Chest\nPain","Diabetes","Heart\nDisease","Joint\nPain")) +
  ylim(c(0,30))+
  ylab("Percent with Condition\n")+
  xlab("\nCondition")+
  geom_segment(aes(x=3.85, y=22.5, xend=3.85, yend=23)) +
  geom_segment(aes(x=3.85, y=23, xend=4.10, yend=23)) +
  geom_segment(aes(x=4.10, y=23, xend=4.10, yend=22.5)) +
  annotate("text", x=4.0, y=23.5, label="**",size=10) +
  
  geom_segment(aes(x=3.6, y=24.5, xend=3.6, yend=25)) +
  geom_segment(aes(x=3.6, y=25, xend=4.10, yend=25)) +
  geom_segment(aes(x=4.10, y=25, xend=4.10, yend=24.5)) +
  annotate("text", x=4, y=25.5, label="***",size=10) +
  
  geom_segment(aes(x=3.6, y=26.5, xend=3.6, yend=27)) +
  geom_segment(aes(x=3.6, y=27, xend=4.4, yend=27)) +
  geom_segment(aes(x=4.4, y=27, xend=4.4, yend=26.5)) +
  annotate("text", x=4.0, y=27.5, label="**",size=10) +
  
  geom_segment(aes(x=2.6, y=17.5, xend=2.6, yend=18)) +
  geom_segment(aes(x=2.6, y=18, xend=3.4, yend=18)) +
  geom_segment(aes(x=3.40, y=18, xend=3.4, yend=17.5)) +
  annotate("text", x=3.0, y=18.5, label="****",size=10) +
  
  geom_segment(aes(x=2.85, y=15.5, xend=2.85, yend=16)) +
  geom_segment(aes(x=2.85, y=16, xend=3.4, yend=16)) +
  geom_segment(aes(x=3.4, y=16, xend=3.4, yend=15.5)) +
  annotate("text", x=3.0, y=16.5, label="*****",size=10) +
  
  geom_segment(aes(x=2.85, y=13.5, xend=2.85, yend=14)) +
  geom_segment(aes(x=2.85, y=14, xend=3.1, yend=14)) +
  geom_segment(aes(x=3.1, y=14, xend=3.1, yend=13.5)) +
  annotate("text", x=3, y=14.5, label="***",size=10) +

  geom_segment(aes(x=3.15, y=13.5, xend=3.15, yend=14)) +
  geom_segment(aes(x=3.15, y=14, xend=3.4, yend=14)) +
  geom_segment(aes(x=3.4, y=14, xend=3.4, yend=13.5)) +
  annotate("text", x=3.25, y=14.5, label="**",size=10) +
  
  geom_segment(aes(x=1.9, y=8, xend=1.9, yend=8.5)) +
  geom_segment(aes(x=1.9, y=8.5, xend=2.1, yend=8.5)) +
  geom_segment(aes(x=2.1, y=8.5, xend=2.1, yend=8)) +
  annotate("text", x=2, y=9.0, label="***",size=10) +
  
  geom_segment(aes(x=1.75, y=10, xend=1.75, yend=10.5)) +
  geom_segment(aes(x=1.75, y=10.5, xend=2.1, yend=10.5)) +
  geom_segment(aes(x=2.1, y=10.5, xend=2.1, yend=10.0)) +
  annotate("text", x=1.8, y=11.0, label="**",size=10) +
  

  geom_segment(aes(x=.9, y=9.5, xend=0.9, yend=10)) +
  geom_segment(aes(x=0.9, y=10, xend=1.1, yend=10)) +
  geom_segment(aes(x=1.1, y=10, xend=1.1, yend=9.5)) +
  annotate("text", x=1, y=10.5, label="*",size=10) +
  
  geom_segment(aes(x=.75, y=11, xend=.75, yend=11.5)) +
  geom_segment(aes(x=.75, y=11.5, xend=1.1, yend=11.5)) +
  geom_segment(aes(x=1.1, y=11.5, xend=1.1, yend=11.0)) +
  annotate("text", x=1, y=12.0, label="****",size=10) +
  
  geom_segment(aes(x=.75, y=12.5, xend=.75, yend=13)) +
  geom_segment(aes(x=.75, y=13, xend=1.3, yend=13)) +
  geom_segment(aes(x=1.3, y=13, xend=1.3, yend=12.5)) +
  annotate("text", x=.9, y=13.5, label="**",size=10) +

  theme_bw(30)+
  scale_fill_manual(values = cour_small)+
  ggtitle("B")+
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
  r <- c(min(x), median(x) - sd(x), median(x), median(x) + sd(x), max(x))
  names(r) <- c("ymin", "lower", "middle", "upper", "ymax")
  r
  
}
# ggplot code
s=subset(merged_k,select=c("clusters","satisfiedwith_life"))
s=s[which(s$clusters %in% c(2,4,5,6)),]
s=na.omit(s)
s$clusters=factor(s$clusters,levels=c(5,2,4,6))
p3 <- ggplot(s, aes(clusters, satisfiedwith_life))+
  geom_boxplot(position="dodge",outlier.colour="black",notch=FALSE)+
  stat_summary(fun.y = mean, geom="point",colour="darkred", size=3)+
  ylab("Life Satisfaction (1-10)\n")+
  xlab("\nActivity Cluster")+
  scale_x_discrete(labels=c("Inactive","Drivers","Weekend\nWarriors","Active")) +
  ylim(c(5,12.5))+
  theme_bw(30)+
  theme(plot.title=element_text(hjust=0))+
  geom_segment(aes(x=2.25, y=10, xend=2.25, yend=10.5)) +
  geom_segment(aes(x=2.25, y=10.5, xend=2.75, yend=10.5)) +
  geom_segment(aes(x=2.75, y=10.5, xend=2.75, yend=10)) +
  annotate("text", x=2.5, y=10.6, label="*",size=10) +
  
  geom_segment(aes(x=1, y=10, xend=1, yend=10.5)) +
  geom_segment(aes(x=1, y=10.5, xend=1.75, yend=10.5)) +
  geom_segment(aes(x=1.75, y=10.5, xend=1.75, yend=10)) +
  annotate("text", x=1.5, y=10.6, label="*****",size=10) +
  
  geom_segment(aes(x=3.25, y=10, xend=3.25, yend=10.5)) +
  geom_segment(aes(x=3.25, y=10.5, xend=4, yend=10.5)) +
  geom_segment(aes(x=4, y=10.5, xend=4, yend=10.0)) +
  annotate("text", x=3.5, y=10.6, label="*",size=10) +

  geom_segment(aes(x=1, y=11, xend=1, yend=11.5)) +
  geom_segment(aes(x=1, y=11.5, xend=4, yend=11.5)) +
  geom_segment(aes(x=4, y=11.5, xend=4, yend=11)) +
  annotate("text", x=2.5, y=11.6, label="*****",size=10) +
  ggtitle("C")+
  theme(plot.title=element_text(hjust=0))

  


#p3 <- ggplot(aes(y = value, x = factor(group)), data = mydata)+
#  stat_summary(fun.data = min.mean.sd.max, geom = "boxplot",size=2)  +
#  ggtitle("c")+
svg(file="Full_Figure2.svg",onefile=TRUE,width=25,height=10)
multiplot(p1, p2, p3, cols=3)
dev.off() 


