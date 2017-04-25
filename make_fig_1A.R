#Rachel Goldfeder

library(plotrix)
library(grid)


# read in data from flurry.
# note that this is collapsed from all downloads 3/9 -3/22 
data <- read.table(text="
Download_(Day_0)  69431 g
Consent 29866 g
Day_1	22621 g
Day_2	17595 g
Day_3	15149 g
Day_4	13647 g
Day_5	12584 g
Day_6	10755 g
Day_7	11369 g", header=F)

data$V1=gsub("\\_", " ", data$V1)
data$V1 <- factor(data$V1, levels = c( "Download (Day 0)", "Consent", "Day 1", "Day 2", "Day 3", "Day 4", "Day 5", "Day 6", "Day 7"))
ggplot(data,aes(x=V1, y=V2))+ ylim(0,70000) + geom_line(aes(group=V3), lty="dashed", colour="blue") + geom_point(size=6, col="blue") +theme_bw(18) +xlab ("") + ylab("Number of People") + ggtitle("Participation") +
  geom_segment(aes(x = "Day 7", y = 35000, xend = "Day 7", yend = 15000), arrow = arrow(angle = 30,type="closed",ends="last")) +
  geom_text(y= 40000, x = 9, aes(label="6 Minute\nWalk"), size=7)

data_noDownload = data[2:nrow(data),]
ggplot(data_noDownload,aes(x=V1, y=V2))+ylim(0,32000) + geom_line(aes(group=V3), lty="dashed", colour="blue") + geom_point(size=6, col="blue") +theme_bw(18) +xlab ("") + ylab("Number of People") + ggtitle("Participation") +
  geom_segment(aes(x = "Day 7", y = 18000, xend = "Day 7", yend = 12000), arrow = arrow(angle = 30,type="closed",ends="last")) +
  geom_text(y= 20000, x = 8, aes(label="6 Minute\nWalk"), size=7)

