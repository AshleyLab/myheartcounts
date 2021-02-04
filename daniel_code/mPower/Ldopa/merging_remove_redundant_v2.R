#source("~/mybiotools/r/", echo=T)
rm(list=ls());
options("scipen"=1, "digits"=4, stringsAsFactors=FALSE);

library(PDdream)
library(caret)

path = "~/PD_dream/Ldopa_proc_raw_features/all_training"
outpath = "~/PD_dream/Ldopa_proc_raw_features/all_training/merged"
method = c("m1", "m10", "m11", "m2", "m3", "m4", "m8", "m9")
min.r = 0.95

dir = paste0(path, "/", "m1", "/", "table")
file = list.files(dir, ".txt$", full.names=T)
file1 = sort(file)
file.basename = basename(file1)

all_data <- vector("list", length(file.basename))
names(all_data) <- file.basename

for (m in method) {
	dir = paste0(path, "/", m, "/", "table")
	file = list.files(dir, ".txt$", full.names=T)
	file = sort(file)
	cat (m, ": ", length(file), "\n")
	if (!all(basename(file) == basename(file1))) stop ("Error: not all files same")
	for (i in 1:length(file)) {
		cat (m, " - ", file.basename[i], " ... \n")
		dat = read.table(file[i],T)
		if (length(grep("_y.txt$", file.basename[i]))==0) colnames(dat) = paste0(m, ".", colnames(dat))
		if (is.null(all_data[[file.basename[i]]]) | length(grep("_y.txt$", file.basename[i]))>0) {
			all_data[[file.basename[i]]] = dat
		} else {
			all_data[[file.basename[i]]] = cbind(all_data[[file.basename[i]]], dat)
		}
	}
}

filter.predictor = function (dat, min.r = 0.9) {
	require(caret)
	#nzv <- nearZeroVar(dat, saveMetrics= TRUE)
	#nzv.num = sum(nzv$nzv)
	#nzv <- nearZeroVar(dat, freqCut = 95/5, uniqueCut = 10)
	dat = scale(dat, scale = T, center = T)
	nzv <- nearZeroVar(dat, freqCut = 5/5, uniqueCut = 20)
	filteredDescr <- dat[, -nzv]
	nzv.num = ncol(dat) - ncol(filteredDescr)
	descrCor <-  cor(filteredDescr)
	highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > min.r)
	highlyCorDescr <- findCorrelation(descrCor, cutoff = min.r)
	dat.o <- filteredDescr[,-highlyCorDescr]
	corr.num = length(highlyCorDescr)
	dim(dat.o)
	dim(dat)
	list(dat=dat.o, nzv.num = nzv.num, corr.num = corr.num)
}


out.log.f = paste0(outpath, "/", "feature_filter_log.tsv")
if (file.exists(out.log.f)) system (paste0("rm -f ", out.log.f))
cat ("File", "ZeroVar.num", "HighCorr.num", "\n", sep="\t", file=out.log.f, append=T)
for (n in 1:length(all_data)) {
	outf = paste0(outpath, "/", names(all_data)[n])
	dat = all_data[[n]]
	cat (n, names(all_data)[n],sep = " | ", "\n")
	if (length(grep("_y.txt$", basename(names(all_data)[n])))==0) {
		ret = filter.predictor(dat, min.r)
		dat.o = ret$dat
		nzv.num = ret$nzv.num
		corr.num=ret$corr.num
		cat (names(all_data)[n], nzv.num, corr.num, "\n", sep="\t", file=out.log.f, append=T)
		cat (names(all_data)[n], nzv.num, corr.num, "\n", sep="\t")
	} else {
		dat.o = dat
	}
	write.table(dat.o, file=outf, sep="\t", quote=F)
}



