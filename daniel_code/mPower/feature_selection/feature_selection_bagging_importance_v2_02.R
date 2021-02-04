#source("~/mybiotools/r/dp_try_part2.R", echo=T)
#used to use Bootstrap Aggregation (Bagging) to produce robust importance
#based on "train.dat.rdata" to limit SNPs

rm(list = ls())
options(scipen = 3, digits = 4, stringsAsFactors = FALSE)
#source("~/mybiotools/r/myfunc.R")

library(PDdream)
library(caret)
#library(dplyr) # Used by caret
#library(kernlab) # support vector machine 
library(pROC) # plot the ROC curves
#library(doMC)

#################SETUP####################
#for cv repeat times
repeats = 2
#for tune length parameter
tuneLength = 4
train_out_rdata = "train.dat.rdata"
bootstrap.num = 200
bootstrap.perc = 0.9
queue = "general"
CPUnum = 20
memory = "100000M"
maxrun = 1000
response.level = c("Cont", "Case")
outd = "bagging_imp_out"
ml.method = c("rf")
outf = paste0(ml.method, "_", bootstrap.num, "_imp.txt")
pdffile = paste0(ml.method, "_", bootstrap.num, "_imp.pdf")
fork_script = "~/mybiotools/r/feature_selection_rf_svm_screen_02_fork_v2.R"
#################SETUP####################

if (file.exists("./bagging_importance_para.R")) 
	source("./bagging_importance_para.R")

#registerDoMC(CPUnum)
if (!file.exists(outd)) {
	dir.create(outd, recursive = T)
}

load(train_out_rdata)
myY = as.factor(train.dat$response)
myX = train.dat[, -ncol(train.dat)]

rem.snp.allele = function(snp.seq) {
	snps = unlist(strsplit(snp.seq, "_.$", perl = T))
	return(snps)
}
colnames(myX) = rem.snp.allele(colnames(myX))

#levels(myY) = c("Cont", "Case")
levels(myY) = response.level
if (length(response.level) != 2 ){
	stop ("Only support case/control response.")
}

#set a seed
set.seed(123)
all.seed = sample(1:1000000, bootstrap.num, replace=F)

sample.num = round(bootstrap.perc * nrow(myX))
pbsids = c()
all_out_rdata = c()
all_out_rdata.name = c()
for (j in 1:bootstrap.num) 
{
	message (paste0("For ", j , " out of ", bootstrap.num, " ... "))
	set.seed(all.seed[j])
	sample.i = sample(1:nrow(myX), sample.num, replace=T)
	in_rdata = paste0(outd, "/_tempin_", j, ".rdata")

	for (method in ml.method) {
		out_rdata = paste0(outd, "/_tempout_", method, "_", j, ".rdata")
		all_out_rdata = c(all_out_rdata, out_rdata)
		all_out_rdata.name = c(all_out_rdata.name, method)

		#making input rdata
		if (!file.exists(in_rdata)) {
			X = myX[sample.i,];
			Y = myY[sample.i];
			save (X, Y, file=in_rdata)
		}

		#training
		if (!file.exists(out_rdata)) {
			CMD = paste("Rscript --max-ppsize=500000", fork_script, CPUnum, in_rdata, method, tuneLength, out_rdata, repeats, sep=" ")
			cat ("CMD: ", CMD, "\n", sep="")
			pbsid = system(paste0("pbsv2.pl \"", CMD, "\"  -ppn ", CPUnum, " -q ", queue, " -pmem ", memory, " -rn ", maxrun), intern=T)
			pbsids = c(pbsids, pbsid)
		}
	}
}
all_pbs_id = paste(pbsids, collapse=" ")
CMD = paste0("check_pbs_state.pl ", all_pbs_id)
cat ("CMD: ", CMD, "\n", sep="")
system(CMD, intern=T)
names(all_out_rdata) = all_out_rdata.name

#obsolote, 09292017
getimportance = function(train.d) {
	imp <- varImp(train.d, scale = FALSE)
	impor = as.data.frame(imp$importance)
	return(impor)
}

library(doParallel)
registerDoParallel(cores = 10)
all.imp = NULL
all.imp <- foreach (k = 1:bootstrap.num, .combine = cbind) %dopar%
#all.imp <- foreach (k = 1:10, .combine = cbind) %dopar%
#for (k in 1:length(all_out_rdata)) 
{
	load(all_out_rdata[[k]])
	#imp.raw = getimportance(svm.tune)
	if (all_out_rdata.name[k] == "svmRadial") {
		imp <- varImp(svm.tune, scale = FALSE)
		imp.raw = as.data.frame(imp$importance)
		imp.zscore = abs(scale(imp.raw, scale = T, center = T))
		imp.zscore = imp.zscore[,2]
	} else if (all_out_rdata.name[k] == "caretEnsemble") {
		imp <- varImp(svm.tune, scale = FALSE)
		imp.raw = imp[,"overall",drop=F]
		imp.zscore = scale(imp.raw, scale = T, center = T)
	} else {
		imp <- varImp(svm.tune, scale = FALSE)
		imp.raw = as.data.frame(imp$importance)
		imp.zscore = scale(imp.raw, scale = T, center = T)
	}
	if (ncol(imp.zscore) == 2) imp.zscore = imp.zscore[,2,drop=F]
	all.imp = cbind(all.imp, imp.zscore)
}
save (all.imp, file="all.imp.rdata")
dim(all.imp)
bootstrap.num
length(all_out_rdata)
colnames(all.imp) = paste0("Random",1:bootstrap.num)

median.imp = apply(all.imp, 1, median, na.rm=T)
median.imp = sort(median.imp, decreasing=T)
head(median.imp)
all.imp.2 = cbind(median.imp, all.imp[names(median.imp),])
#all.imp.zscore = myscale(all.imp.2, "column")
library(limma)
#all.imp.zscore = normalizeBetweenArrays(all.imp.2, method="quantile")
all.imp.zscore = all.imp.2
head(all.imp.zscore[ ,1:5])
w.table(all.imp.zscore, file=outf, col.names=T, row.names=T, col1name="Feature")

plot.row.num = ifelse(bootstrap.num > 101, 101, bootstrap.num)
plot.col.num = ifelse(ncol(all.imp.zscore) > 101, 101, ncol(all.imp.zscore))
mat = all.imp.zscore[1:plot.row.num, 1:plot.col.num]
#mat = all.imp.zscore[1:200, ]
library(corrplot)
library(pheatmap)
pdf(pdffile, 30, 30)
corrplot(mat, is.corr=FALSE, na.label = "NA")
pheatmap(mat, cluster_rows=F, cluster_cols=F)
dev.off()





