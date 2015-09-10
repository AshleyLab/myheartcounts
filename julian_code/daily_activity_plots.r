## HealthKit Download Plotting from Aleks
library(ggplot2)
setwd("/Users/Julian/Documents/AshleyLab/MHealth/DemoFromAleks")

activeUsers = read.table("Active Users Flurry.csv", sep=",", head=T)
activeUsers = subset(activeUsers, Incomplete!="*")
names(activeUsers) <- c("Incomplete", "Date", "NumActive", "PercentActive")
activeUsers$Day = as.Date(activeUsers$Date, format="%m/%d/%Y")
ggplot(aes(x=Day, y=NumActive), data=activeUsers) + geom_bar(stat="Identity") + theme_bw() + theme(axis.text.x=element_text(size=16), axis.title.y=element_text(size=16), axis.text.y=element_text(size=16), axis.title.x=element_blank()) + labs(y="Number of Active Users")
ggsave("NumberActivePerDay.pdf", height=6, width=6)

activeUsers$NumPercentActive = as.numeric(sub("%", "", activeUsers$PercentActive))


## Percent Active By Day
ggplot(aes(x=Day, y=NumPercentActive), data=activeUsers) + geom_bar(stat="Identity") + theme_bw() + theme(axis.text.x=element_text(size=16), axis.title.y=element_text(size=16), axis.text.y=element_text(size=16), axis.title.x=element_blank()) + labs(y="Percentage of Users Active")
ggsave("PercentageActivePerDay.pdf", height=6, width=6)

daily_downloads = data.frame(t(read.csv("Download data from itunes.csv", head=F, row.names=1)))
daily_downloads$Date = as.Date(daily_downloads$Date, format="%m/%d/%Y")
daily_downloads$USA.and.Canada = as.numeric(as.character(daily_downloads$USA.and.Canada))
ggplot(aes(x=Date, y=USA.and.Canada), data=daily_downloads) + geom_bar(stat = "Identity") + theme_bw() + theme(axis.text.x=element_text(size=16), axis.title.y=element_text(size=16), axis.text.y=element_text(size=16), axis.title.x=element_blank()) + labs(y="Number of Daily Downloads")
ggsave("DailyDownloads.pdf", height=6, width=6)

## Overall Retention

retention = read.csv("overallRetention.csv")
retention$numeric = as.numeric(sub("%","", retention$Overall))
ggplot(aes(x=Install.Date, y=numeric), data=retention) + geom_bar(stat = "Identity") + theme_bw() + theme(axis.text.x=element_text(size=16), axis.title.y=element_text(size=16), axis.text.y=element_text(size=16), axis.title.x=element_text(size=16)) + labs(y="Percent Retention", x= "Days Since Install")
ggsave("RetentionRate.pdf", height=6, width=6)

