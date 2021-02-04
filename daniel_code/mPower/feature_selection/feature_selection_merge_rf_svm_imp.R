#!/usr/bin/env Rscript
#source("~/mybiotools/r/", echo=T)
#rm(list=ls());
options("scipen"=1, "digits"=4, stringsAsFactors=FALSE);

library(PDdream)

args<-commandArgs(T)

rf_impf = args[1]
svm_impf = args[2]
outf = args[3]
header1 = args[4]
header2 = args[5]

if (is.na(rf_impf)) rf_impf = "../bagging_importance_rf/rf_1000_imp.txt"
if (is.na(svm_impf)) svm_impf = "../bagging_importance_svm/svmRadial_1000_imp.txt"
if (is.na(outf)) outf = "merge_svm_rf_imp.txt"

rf_imp = r.table(rf_impf, T, )
svm_imp = r.table(svm_impf, T)

ft.name = names(rf_imp)[1]
if (names(svm_imp)[1] != ft.name) stop ("Not same 1st col name. ")
all_imp = merge(rf_imp[,1:2], svm_imp[,1:2], by=ft.name)
all_imp$ml1.scaled = scale (all_imp[,2] ,scale = T, center = T)
all_imp$ml2.scaled = scale (all_imp[,3] ,scale = T, center = T)
colnames(all_imp) = c("Feature", header1, header2, paste0(header1, ".scaled"), paste0(header2, ".scaled"))
str(all_imp)

library(limma)
imp.scaled.normalized = data.frame(normalizeBetweenArrays(all_imp[,4:5], method="quantile"))
imp.scaled.normalized = cbind(sum_imp = as.numeric(apply(imp.scaled.normalized, 1, sum)), imp.scaled.normalized)
imp.scaled.normalized = cbind(Feature= all_imp$Feature, imp.scaled.normalized)
o.i = order(imp.scaled.normalized$sum_imp, decreasing=T)
all_imp.out = imp.scaled.normalized[o.i, ]
head(all_imp.out)
w.table(all_imp.out,outf,T)

#####debug
rf_impf = "../bagging_importance_rf/rf_500_imp.txt"
svm_impf = "../bagging_importance_svm/svmRadial_500_imp.txt"
outf = "merge_svm_rf_imp.txt"

