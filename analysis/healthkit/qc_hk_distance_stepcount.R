rm(list=ls())
library(ggplot2)
library(dplyr)
library(tidyr)
data_dir="~/sherlock/data/timeseries_v2/summary"
motion_df=read.table(paste(data_dir,"motion_tracker_combined.txt",sep='/'),header=TRUE,sep='\t',stringsAsFactors = FALSE)
steps_df=read.table(paste(data_dir,"healthkit_combined.stepcount.txt",sep='/'),header=TRUE,sep='\t',stringsAsFactors = FALSE)
dist_df=read.table(paste(data_dir,"healthkit_combined.distance.txt",sep='/'),header=TRUE,sep='\t',stringsAsFactors = FALSE)

#filter to the columns we want 
motion_subset=subset(motion_df,select=c("Subject","DayIndex","Activity","Fraction"))
steps_subset=subset(steps_df,select=c("Subject","DayIndex", "Metric","Value"))
dist_subset=subset(dist_df,select=c("Subject","DayIndex","Metric","Value"))

names(motion_subset)=c("Subject","DayIndex","Metric","Value")
names(steps_subset)=c("Subject","DayIndex","Metric","Value")
names(dist_subset)=c("Subject","DayIndex","Metric","Value")

#merge across the three data frames 
data=rbind(motion_subset,steps_subset,dist_subset)

myPalette=c("#e6194b",
            "#3cb44b",
            "#ffe119",
            "#0082c8",
            "#f58231",
            "#911eb4",
            "#46f0f0",
            "#f032e6",
            "#d2f53c",
            "#fabebe",
            "#008080",
            "#e6beff",
            "#aa6e28",
            "#fffac8",
            "#800000",
            "#000000")


#pick a subject 
subjects=unique(data$Subject)
for(s in subjects)
{
ds=data[data$Subject==s,] 
p=ggplot(ds,aes(x=DayIndex,y=Value,color=Metric,group=Metric))+
  geom_point(size=3)+
  geom_line(size=0.5)+
  scale_color_manual(values=myPalette)+
  scale_y_continuous(trans='log10')+
  ggtitle(s)
png(paste(s,'png',sep='.'))
print(p)
dev.off()
print(s)
}