library(data.table)
library(ggplot2)
library(reshape2)
source('helpers.R')
library('RColorBrewer')
pal="Dark2"
cour <- brewer.pal(6, pal)
palette(cour)
#Sup Fig 8 A 
load("BREAKS")
p1<-ggplot(data,aes(changes_day,changes_end,colour = Cluster)) + 
  geom_point(alpha=1/2,size=5) + 
  xlab("Weekday")+
  ylab("Weekend")+
  ggtitle("A")+
  theme_bw(30)+
  theme(plot.title=element_text(hjust=0))+
  scale_colour_brewer(palette=pal)

#Sup Fig 8 B 

data=data.frame(read.table('chisquared.nop.csv',header=T,sep='\t'))
mdf<- melt(data, id="Cluster")  # convert to long format
p2=ggplot(data=mdf,
         aes(x=variable, y=value,colour=Cluster,group=Cluster)) + 
  geom_point(aes(color=factor(Cluster)),size=5)+
  geom_line(aes(color=factor(Cluster)))+
  scale_x_discrete(labels=c("Chest\nPain","Diab.","Heart\nCond.","Heart\nDis.","Hyper.","Joint\nProb.","Vasc.\nDis.")) +
  scale_colour_manual(breaks = c("1", "2", "3", "4", "5", "6"),
                      labels = c("1", "2", "3", "4", "5", "6"),
                      values = cour)+
  theme_bw(30)+
  xlab("Medical Condition")+
  ylab("Obs.-Exp. Std. Res.")+
  ggtitle("B")+
  theme(legend.position = "none")+
  theme(plot.title=element_text(hjust=0))



#Sup Fig 8 C 
load("motion_tracker_merged_df")
load("clustered_activity_state.bin")

proportions=subset(merged_df,select=c("Walking_weekday","Walking_weekend", "Running_weekday","Running_weekend","Cycling_weekday","Cycling_weekend","Stationary_weekday","Stationary_weekend","Automotive_weekday","Automotive_weekend","Unknown_weekday","Unknown_weekend"))
clusterinfo=subset(merged,select=c("subject","cluster","work","atwork","phys_activity","moderate_act","vigorous_act"))
data=merge(clusterinfo,proportions,by.x="subject",by.y="row.names",all=TRUE)
jobtype=table(data$atwork,data$cluster)
jobtypenorm=jobtype
cs=colSums(jobtype)
jobtypenorm["1",]=jobtype["1",]/cs
jobtypenorm["2",]=jobtype["2",]/cs
jobtypenorm["3",]=jobtype["3",]/cs
jobtypenorm["4",]=jobtype["4",]/cs
jobtypenorm=as.data.frame(jobtypenorm)

palette(gray.colors(4))
names(jobtypenorm)=c("Activity","Cluster","Freq")
p3<-ggplot(jobtypenorm,aes(x=factor(Cluster),y=Freq))+
  geom_bar(aes(fill=Activity),stat="identity",position="dodge")+
  theme_bw(30)+
  xlab("Cluster")+
  ylab("Fraction of Subjects")+
  ggtitle("C")+
  theme(plot.title=element_text(hjust=0))+
  scale_fill_manual(name="",
                                          breaks=c("1", "2", "3","4"),
                                          labels=c("Sit/Stand", "Walk", "Mod. Exert.","Hard Labor"),
                                          values=c("gray30","gray59","#C3C3C3","#E6E6E6"))+
  theme(legend.position = "bottom")
multiplot(p1,p2,p3,cols=3)
