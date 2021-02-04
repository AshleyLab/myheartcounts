#source("~/mybiotools/r/", echo=T)
rm(list=ls());
options("scipen"=1, "digits"=4, stringsAsFactors=FALSE);
source("~/mybiotools/r/myfunc.R");

training.indepdentTest.rdata.path = "~/PD_dream/Ldopa_mergingTask_FS"
final.path = "~/PD_dream//Ldopa_final_features"

sub.name = c("Tremor", "Bradykinesia", "Dyskinesia")
final.csv = c("sub2_1_Tremor_fs.csv", "sub2_3_Bradykinesia_fs.csv", "sub2_2_Dyskinesia_fs.csv")
CPUnum = 20

library(doParallel)
registerDoParallel(cores = CPUnum)

for (i in 1:length(sub.name)) {
	name = sub.name[i]
	train.rdata.f = paste0(training.indepdentTest.rdata.path, "/", name, "/train.dat.rdata")
	testing.rdata.f = paste0(training.indepdentTest.rdata.path, "/", name, "/testing.XY.rdata")
	load(train.rdata.f)
	myY = train.dat[,ncol(train.dat)]
	myX = train.dat[,-ncol(train.dat)]
	load(testing.rdata.f)
	if (!all(colnames(myX) == colnames(X))) stop ("colnames error.")

#filter idx
	final.f = paste0(final.path, "/", final.csv[i])
	final.d = read.csv(final.f,T, row.names="dataFileHandleId")
	required.fileid = rownames(final.d)
	required.features = colnames(final.d)

	f.i = match(required.features, colnames(X))
	if (sum(is.na(f.i))>0) stop ("feature name error")

	f.i = match(required.fileid, rownames(myX), nomatch=0)
	myX2 = myX[f.i,]
	f.i = match(required.fileid, rownames(X), nomatch=0)
	X2 = X[f.i,]
	dim(myX2)
	dim(X2)

	output <-
		foreach (j = 1:length(required.features), .combine = rbind) %dopar%
		{
			fit = t.test(myX2[,required.features[j]], X2[,required.features[j]])
			pv = fit$p.value
			c(required.features[j], pv)
		}
	output = data.frame(output)
	output[,2] = signif(as.numeric(output[,2]), 3)
	colnames(output) = c("Feature", "t.test.P")


}
