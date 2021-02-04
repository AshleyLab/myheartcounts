#!/usr/bin/env Rscript
#merging m1 - m11 first, then split into training & testing
options("scipen"=1, "digits"=4, stringsAsFactors=FALSE);
#source("~/mybiotools/r/myfunc.R");

library(PDdream)


#training.indepdentTest.rdata.path = "~/PD_dream/Ldopa_mergingTask_FS"
training.indepdentTest.rdata.path = "~/PD_dream/Ldopa_PostTtest_FS"
feature.data.path = "~/PD_dream/Ldopa_proc_raw_features/all_training/merged_v3"

#which fileid is must
LdopaTraining = load_obj("~/PD_dream/download_LdopaTraining_data/LdopaTraining.rdata")
LdopaTesting = load_obj("~/PD_dream/download_LdopaTesting_data/LdopaTesting.rdata")

sub.name = c("Tremor", "Bradykinesia", "Dyskinesia")
sub.num = c("2_1", "2_3", "2_2")
test.f = c("test_tremor.txt", "test_brady.txt", "test_dys.txt")
training.f = c("data_tremor.txt", "data_brady.txt", "data_dys.txt")
template.f = c("~/PD_dream/tremorSubmissionTemplate.csv", "~/PD_dream/bradykinesiaSubmissionTemplate.csv", "~/PD_dream/dyskinesiaSubmissionTemplate.csv") 

idx2file.testing = function (idx) {
	#for training
	dat = load_obj("~/PD_dream/download_LdopaTesting_data/LdopaTesting.rdata")
	ind = match(idx, dat$idx)
	if (sum(is.na(ind)) > 0 ) stop ("some idx not match")
	dataFileHandleId = dat$dataFileHandleId[ind]
	dataFileHandleId
}

idx2file = function (idx) {
	#for training
	dat = load_obj("~/PD_dream/download_LdopaTraining_data/LdopaTraining.rdata")
	ind = match(idx, dat$idx)
	if (sum(is.na(ind)) > 0 ) stop ("some idx not match")
	dataFileHandleId = dat$dataFileHandleId[ind]
	dataFileHandleId
}


for (i in 1:length(sub.name)) {
	name = sub.name[i]
	subname = sub.num[i]
	outf.name = paste0("sub", subname, "_", name, "_fs_v2.csv")
	print ("")
	print (paste("processing", subname, name, " ...  ", outf.name))

	#reading testing feature data
	test.dat.f = paste0(feature.data.path, "/", test.f[i])
	dat.test = read.table(test.dat.f, T)
	fileh = idx2file.testing(rownames(dat.test))
	rownames(dat.test) = fileh

	#reading training feature data
	training.dat.f = paste0(feature.data.path, "/", training.f[i])
	dat.train = read.table(training.dat.f, T)
	fileh = idx2file(rownames(dat.train))
	rownames(dat.train) = fileh
#for missing fileid
	#missing.id = setdiff(ta.must, fileh)

	#loading FS data
	rdata.f = paste0(training.indepdentTest.rdata.path, "/", name, "/Feature_selection/Independent_test/pred.accu.rdata")
	pred.accu = load_obj(rdata.f)
	roc = lapply(pred.accu, function(x) {
				 roc.i = grep ("ROC", colnames(x))
				 x[, roc.i]
})
	roc.m = t(do.call(rbind, roc))
	roc.m = as.data.frame(roc.m)
	roc.m$mean.roc = apply(roc.m, 1, mean, na.rm=T)
	roc.m = roc.m[order(roc.m$mean.roc, decreasing=T), ]
	snp.num = sub("Featurs_", "", rownames(roc.m)[1] )
	snp.num = as.numeric(snp.num)

	if (i == 1) {
		snp.num = 680 #manully selected for ver 2
		roc.mean = roc.m[paste0("Featurs_", snp.num), "mean.roc"]
	} else {
		roc.mean = roc.m$mean.roc[1]
	}

	print (paste0("Best performance features. Number: ", snp.num, " ; mean ROC: ", roc.mean))
	imp.ranking.f = paste0(training.indepdentTest.rdata.path, "/", name, "/bagging_importance_rf/rf_500_imp.txt")
	feature.name = r.table(imp.ranking.f, T)[1:snp.num,1]

	#output
	m.i = match(feature.name, colnames(dat.train))
	if (sum(is.na(m.i))>0) stop ("Not all feature names were mapped.")
	out.dat.train = dat.train[, feature.name]
	m.i = match(feature.name, colnames(dat.test))
	if (sum(is.na(m.i))>0) stop ("Not all feature names were mapped.")
	out.dat.test = dat.test[, feature.name]
	#print (dim(out.dat.test))
	#print (dim(out.dat.train))
	out.dat = rbind(out.dat.train, out.dat.test)
	print (paste0("dataFileHandleId number: "))
	print (dim(out.dat)[1])
	print (paste0("Features number: "))
	print (dim(out.dat)[2])

	#filter fileid
	all.must_fileid = read.csv(template.f[i], T)[,1]
	print (paste0("Required dataFileHandleId number: ", length(all.must_fileid)))
	ind = match(all.must_fileid, rownames(out.dat))
	print (paste0("    Total Matched dataFileHandleId number: ", sum(!is.na(ind))))
	out.dat2 = out.dat[ind,]
	if (sum(is.na(ind))>0) {
		na.i = which(is.na(ind))
		print (paste0("    ", sum(is.na(ind)), " fileHandleIds need to be imputed."))
		rownames(out.dat2)[na.i] = all.must_fileid[na.i]
	}

	#imputation
	out.dat = out.dat2
	if (sum(is.na(out.dat))>0) {
		print (paste0(sum(is.na(out.dat)), " NA values need to be imputed."))
		for(i in 1:ncol(out.dat)){
			out.dat[is.na(out.dat[,i]), i] <- mean(out.dat[,i], na.rm = TRUE);
		}
	}

	out.dat = signif (out.dat, 3)
	w.table(out=out.dat, file=outf.name, row.names=T, col.names=T, col1name="dataFileHandleId", sep=",", quote=F)
}



