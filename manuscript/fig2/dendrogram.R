rm(list=ls())
load("object_merged_k")
sub=merged_k[which(merged_k$clusters %in% c(2,4,5,6)),]
attach(sub)
aov.joint<-pairwise.t.test(jointProblem,clusters,pool.sd = T,p.adjust.method = "fdr") 
aov.heart<-pairwise.t.test(heart_disease,clusters,pool.sd = T,p.adjust.method = "fdr")
