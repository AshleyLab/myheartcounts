rm(list=ls()) 
#LOAD THE HIERARCHICAL AND K-MEANS CLUSTERING OBJECTS 
load("object_merged_k") 
attach(merged_k) 

png('kmeans_vs_illness.png',width=8.25,height=6.25,units="in",res=600)
par(mar=c(2,2,2,2))
par(mfrow=c(2,3))
plot(satisfiedwith_life~clusters,data=merged_k,main="Satisfied with Life")
means <- aggregate(satisfiedwith_life ~  clusters, merged_k, mean)
points(means,col="red")

plot(feel_worthwhile1~clusters,data=merged_k,main="Feel Worthwhile")
means <- aggregate(feel_worthwhile1 ~  clusters, merged_k, mean)
points(means,col="red")

plot(feel_worthwhile2~clusters,data=merged_k,main="Feel Happy")
means <- aggregate(feel_worthwhile2 ~  clusters, merged_k, mean)
points(means,col="red")

plot(feel_worthwhile3~clusters,data=merged_k,main="Feel Depressed")
means <- aggregate(feel_worthwhile3 ~  clusters, merged_k, mean)
points(means,col="red")

plot(feel_worthwhile4~clusters,data=merged_k,main="Feel Worried")
means <- aggregate(feel_worthwhile4 ~  clusters, merged_k, mean)
points(means,col="red")
dev.off() 

aov1<-aov(satisfiedwith_life~clusters,data=merged_k)
tk<-TukeyHSD(aov1,conf.level=0.95)
capture.output(tk, file = "emotion.satisfied.tukey.txt")

aov2<-aov(feel_worthwhile1~clusters,data=merged_k)
tk<-TukeyHSD(aov2,conf.level=0.95)
capture.output(tk, file = "emotion.worthwhile.tukey.txt")


aov3<-aov(feel_worthwhile2~clusters,data=merged_k)
tk<-TukeyHSD(aov3,conf.level=0.95)
capture.output(tk, file = "emotion.happy.tukey.txt")

aov4<-aov(feel_worthwhile3~clusters,data=merged_k)
tk<-TukeyHSD(aov4,conf.level=0.95)
capture.output(tk, file = "emotion.depressed.tukey.txt")

aov5<-aov(feel_worthwhile4~clusters,data=merged_k)
tk<-TukeyHSD(aov5,conf.level=0.95)
capture.output(tk, file = "emotion.worried.tukey.txt")
