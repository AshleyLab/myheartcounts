rm(list=ls())
library(ggplot2)
data=read.table("pca_inputs.txt",header=TRUE,sep='\t')
p1=ggplot(data=data,aes(x=PC1,y=PC2,group=Ethnicity,color=Ethnicity))+
  geom_point(alpha=0.9)+
  xlab("PC1")+
  ylab("PC2")+
  ggtitle("Pop Strat PC1 vs PC2 for 1289 subjects")+
  scale_color_manual(values=c("#e6194b",
                              "#3cb44b",
                              "#f58231",
                              "#0082c8",
                              "#aa6e28",
                              "#808080",
                              "#000000"))+
                              theme_bw()
p2=ggplot(data=data,aes(x=PC2,y=PC3,group=Ethnicity,color=Ethnicity))+
  geom_point()+
  xlab("PC2")+
  ylab("PC3")+
  ggtitle("Pop Strat PC2 vs PC3 for 1289 subjects")+
  scale_color_manual(values=c("#e6194b",
                              "#3cb44b",
                              "#f58231",
                              "#0082c8",
                              "#aa6e28",
                              "#808080",
                              "#000000"))+
  theme_bw()

p3=ggplot(data=data,aes(x=PC1,y=PC3,group=Ethnicity,color=Ethnicity))+
  geom_point()+
  xlab("PC1")+
  ylab("PC3")+
  ggtitle("Pop Strat PC1 vs PC3 for 1289 subjects")+
  scale_color_manual(values=c("#e6194b",
                              "#3cb44b",
                              "#f58231",
                              "#0082c8",
                              "#aa6e28",
                              "#808080",
                              "#000000"))+
  theme_bw()

#REMOVING UNKNOWN CATEGORY: 
data=data[data$Ethnicity!="Unknown",]
p4=ggplot(data=data,aes(x=PC1,y=PC2,group=Ethnicity,color=Ethnicity))+
  geom_point()+
  xlab("PC1")+
  ylab("PC2")+
  ggtitle("Pop Strat PC1 vs PC2 for 1289 subjects")+
  scale_color_manual(values=c("#e6194b",
                              "#3cb44b",
                              "#f58231",
                              "#0082c8",
                              "#aa6e28",
                              "#000000"))+
  theme_bw()
p5=ggplot(data=data,aes(x=PC2,y=PC3,group=Ethnicity,color=Ethnicity))+
  geom_point()+
  xlab("PC2")+
  ylab("PC3")+
  ggtitle("Pop Strat PC2 vs PC3 for 1289 subjects")+
  scale_color_manual(values=c("#e6194b",
                              "#3cb44b",
                              "#f58231",
                              "#0082c8",
                              "#aa6e28",
                              "#000000"))+
  theme_bw()

p6=ggplot(data=data,aes(x=PC1,y=PC3,group=Ethnicity,color=Ethnicity))+
  geom_point()+
  xlab("PC1")+
  ylab("PC3")+
  ggtitle("Pop Strat PC1 vs PC3 for 1289 subjects")+
  scale_color_manual(values=c("#e6194b",
                              "#3cb44b",
                              "#f58231",
                              "#0082c8",
                              "#aa6e28",
                              "#000000"))+
  theme_bw()

