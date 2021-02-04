#used to find the best performance point in the top list of predictors
#based on "train.dat.dat.rdata"
#v3: support validation data set

rm(list = ls())
options(scipen = 3, digits = 4, stringsAsFactors = FALSE)
#source("~/mybiotools/r/myfunc.R")

library(caret)
#library(dplyr) # Used by caret
#library(kernlab) # support vector machine 
library(pROC) # plot the ROC curves
#library(doMC)

#now supported algorithms
all.ml.algorithm = c("svmRadial", "rf", "nb", "xgbTree", "nnet", "caretEnsemble", "knn", "glmnet", "svmLinear")
ensemble.mem = "100000M"
comm.mem = "100000M"
maxrun = 305

snp.rank.f = ""
snp.rank.f.header = F

#for cv repeat times
repeats = 2
#for tune length parameter
tuneLength = 4

outdir = "FS_02out"
train_out_rdata = "train.dat.rdata"
response.level = c("Cont", "Case")

ml.algorithm = c("svmLinear")
resample.num = 20 #for caretEnsemble

#for slurm in Yale
queue = "general"

###for snp number range####
snp.num = NULL
from = 20
to = NA
length.out = 30
validation_rdata = NULL

if (file.exists("./feature_selection_para.R")) 
	source("./feature_selection_para.R")

if (sum(is.na(match(ml.algorithm, all.ml.algorithm))) > 0) {
	stop ("ml.algorithm has to be one of all.ml.algorithm")
}

#registerDoMC(CPUnum)
if (!file.exists(outdir)) {
	dir.create(outdir, recursive = T)
}

load(train_out_rdata)

###adding in 09/16/2017
#for binding validation set to training, and set index 
if (!is.null(validation_rdata)) {
	if (file.exists(validation_rdata)) {
		load(validation_rdata)
		snp.i = match(colnames(train.dat)[-ncol(train.dat)], colnames(X))
		if (sum(is.na(snp.i)) > 0) stop ("Not all features in training set can be found in validation set")
		if (!is.factor(Y)) {
			Y = as.factor(Y)
			levels(Y) = response.level
		}
		#valid.dat = data.frame(cbind(X[,snp.i], response=as.factor(as.numeric(as.factor(Y)))), check.names=F)
		valid.dat = data.frame(cbind(X[,snp.i], response=Y), check.names=F)
		val.index = 1:nrow(train.dat)
		train.dat = rbind(train.dat, valid.dat)
		#training sample size: 94% ~ 98% total traing sample
		num.t = length(val.index)
		traing.size = sample(as.integer(num.t * 0.94):as.integer(num.t * 0.98), 1)
		val.index.list = createResample(sample(val.index, traing.size, replace=F), resample.num)
		save(val.index.list, file="val.index.list.rdata")
	} else {
		stop ("validation_rdata parameter error. File not exists")
	}
}

myY = as.factor(train.dat[, "response"])
myX = train.dat[, -ncol(train.dat)]

rem.snp.allele = function(snp.seq) {
	snps = unlist(strsplit(snp.seq, "_.$", perl = T))
	return(snps)
}

if (file.exists(snp.rank.f)) {
	cat("snp.rank.f: ", snp.rank.f, "\n")
	cat("\n")
	snp.pv = read.table(snp.rank.f, snp.rank.f.header, sep = "\t")
	snp.pv = na.omit(snp.pv)
	dim(snp.pv)
	#!!! suppose then SNP is ranked with importance (the more, the better)
	pv.order = order(snp.pv[, 2], decreasing=T) #!!!if ranked with Pvalue, should change here to decreasing=F
	snp.chosen = snp.pv[pv.order, 1]

	#for plink raw format SNP name difference
	x.name = colnames(myX)
	x.name = rem.snp.allele(x.name)
	#col.i = match(x.name, snp.chosen)
	col.i2 = match(snp.chosen, x.name, nomatch=0)
	#col.i2 = which(x.name %in% snp.chosen)
	#if (length(col.i) != ncol(myX)) {
	#if (sum(is.na(col.i)) > 0 |  sum(is.na(col.i2)) > 0) {
	#	stop(paste0("Wrong length of col.i (not all predictors are in importance file): ", col.i, " != ", ncol(myX)))
	#}
	myX = myX[, col.i2]
} else {
	message("No snp.rank.f. Now suppose the SNPs were sorted in a correct order. ")
}
#levels(myY) = c("Cont", "Case")
levels(myY) = response.level
fork_script = "~/mybiotools/r/feature_selection_rf_svm_screen_02_fork_v2.R"

if (is.null(snp.num)) {
	to = ifelse (is.na(to), ncol(myX), to)
	(snp.num = rev(as.integer(seq(from = from, to = to, length.out = length.out))))
}
#for test
#(snp.num = as.integer(seq(from = 50, to = 100, length.out = 2)))

n = length(snp.num)
pbsids = c()
#rdata_rf = c()
#rdata_svm = c()
#rdata_nb = c()
#rdata_nnet = c()
all_rdata <- vector("list", length(ml.algorithm))
names(all_rdata) <- ml.algorithm
for (j in 1:n) 
{
	message (paste0("For ", j , " out of ", n, " ... "))
	in_rdata = paste0(outdir, "/_tempin_", snp.num[j], ".rdata")

	for (k in 1:length(ml.algorithm)) 
	{
		my.method  =  ml.algorithm[k]
		out_rdata = paste0(outdir, "/_tempout_", my.method, "_", snp.num[j], ".rdata")
		#all_rdata[[k]][[j]] = out_rdata
		all_rdata[[my.method]] = append(out_rdata, all_rdata[[my.method]])
		if (!file.exists(in_rdata)) {
			X = myX[, 1:snp.num[j]];
			Y = myY;
			save (X, Y, file=in_rdata)
		}

		if (!file.exists(out_rdata)) {
			if (!is.null(validation_rdata)) {
				CMD = paste("Rscript --max-ppsize=500000", fork_script, CPUnum, in_rdata, my.method, tuneLength, out_rdata, repeats, "val.index.list.rdata", sep=" ")
			} else {
				CMD = paste("Rscript --max-ppsize=500000", fork_script, CPUnum, in_rdata, my.method, tuneLength, out_rdata, repeats, sep=" ")
			}
			cat ("CMD: ", CMD, "\n", sep="")
			if (my.method == "caretEnsemble") {
				pbsid = system(paste0("pbsv2.pl \"", CMD, "\"  -ppn ", CPUnum, " -q ", queue, " -pmem ", ensemble.mem, " -rn ", maxrun), intern=T)
			} else {
				pbsid = system(paste0("pbsv2.pl \"", CMD, "\"  -ppn ", CPUnum, " -q ", queue, " -pmem ", comm.mem, " -rn ", maxrun), intern=T)
			}
			pbsids = c(pbsids, pbsid)
		}
	}
}
#names(all_rdata) = ml.algorithm

all_pbs_id = paste(pbsids, collapse=" ")
CMD = paste0("check_pbs_state.pl ", all_pbs_id)
cat ("CMD: ", CMD, "\n", sep="")
system(CMD, intern=T)

(n.o = paste0("Featurs_", snp.num))

all.ml.tune = list()
for (i in 1:length(all_rdata)) {
	ml.method = names(all_rdata)[i]
	ml.rdata = all_rdata[[i]]
	caret.tune.all = list()
	k = 1
	for (d in ml.rdata) {
		load(d)
		caret.tune.all[[k]] = svm.tune
		k = k + 1
	}
	names(caret.tune.all) = rev(n.o)
	all.ml.tune[[i]] = caret.tune.all
}
names(all.ml.tune) = ml.algorithm

#pdf width and height, DF: 7
pdf_dpi = 7
if (length.out > 40) pdf_dpi = length.out / 100 * 15

for (i in 1:length(all.ml.tune)) {
	ml.method = names(all.ml.tune)[i]
	FS_02out = paste0(outdir, "/", ml.method)
	if (!file.exists(FS_02out)) {
		dir.create(FS_02out, recursive = T)
	}
	output.f.rdata = paste0(FS_02out, "/output_", ml.method, ".rdata")
	out.rdata = all.ml.tune[[i]]
	#if (!file.exists(output.f.rdata)) 
	save(out.rdata, file = output.f.rdata)

	if (ml.method != "caretEnsemble") {
		require(Rmisc)
		pdffile = paste0(FS_02out, "/", ml.method, "_feature_selection_plot.pdf")
		rValues <- resamples(out.rdata)
		(out = summary(rValues))
		m = length(rValues$metrics)
		p1 = bwplot(rValues, layout = c(m,1))
		p2 = dotplot(rValues, layout = c(m,1))
		pdf(pdffile, pdf_dpi, pdf_dpi)
		print(p1)
		print(p2)
		dev.off()
	}
}

#system(paste0("rm -f FS_02out/_temp*rdata"))


