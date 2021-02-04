library(ggplot2)

load('object_merged_k')
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
  stat_summary(fun.data = min.mean.sd.max, geom = "boxplot")  +
  ggtitle("c")+
  ylab("Life Satisfaction (1-10)\n")+
  xlab("\nActivity Cluster")+
  scale_x_discrete(labels=c("Inactive","Drivers","Weekend\nWarriors","Active")) +
  theme_bw(20)+
  theme(plot.title=element_text(hjust=0))


