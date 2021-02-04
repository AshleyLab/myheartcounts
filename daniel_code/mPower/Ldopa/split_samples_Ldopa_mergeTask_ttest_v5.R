#!/usr/bin/env Rscript
#merging m1 - m11 first, then split into training & testing
options("scipen"=1, "digits"=4, stringsAsFactors=FALSE);
#source("~/mybiotools/r/myfunc.R");

library(caret)
library(dplyr)
library(PDdream)

args<-commandArgs(T)

type = as.character(args[1]) # T, B , D
#type = "t"
#response_col = args[3] #  "tremorScore", "bradykinesiaScore",  "dyskinesiaScore"
#ifcasecontrol = as.logical(args[4]) # F, T, T

#twofiles = c("ramr", "raml", "ftnl", "ftnr")

min.r = 0.95 #for filter

ifcasecontrol = T
if (type == "t") {
	dataf = "data_tremor.txt"
	testf = "test_tremor.txt"
	responsef = "data_tremor_y.txt"
	response_col = "tremorScore"
	templatef = "~/PD_dream/tremorSubmissionTemplate.csv"
	ifcasecontrol = F
} else if (type == "b") {
	dataf = "data_brady.txt"
	testf = "test_brady.txt"
	responsef = "data_brady_y.txt"
	response_col = "bradykinesiaScore"
	templatef = "~/PD_dream/bradykinesiaSubmissionTemplate.csv"
} else if (type == "d") {
	dataf = "data_dys.txt"
	testf = "test_dys.txt"
	responsef = "data_dys_y.txt"
	response_col = "dyskinesiaScore"
	templatef = "~/PD_dream/dyskinesiaSubmissionTemplate.csv"
}

idx2file = function (idx) {
	#for training
	dat = load_obj("~/PD_dream/download_LdopaTraining_data/LdopaTraining.rdata")
	ind = match(idx, dat$idx)
	if (sum(is.na(ind)) > 0 ) stop ("some idx not match")
	dataFileHandleId = dat$dataFileHandleId[ind]
	dataFileHandleId
}

idx2file.testing = function (idx) {
	#for testing
	dat = load_obj("~/PD_dream/download_LdopaTesting_data/LdopaTesting.rdata")
	ind = match(idx, dat$idx)
	if (sum(is.na(ind)) > 0 ) stop ("some idx not match")
	dataFileHandleId = dat$dataFileHandleId[ind]
	dataFileHandleId
}


filter.predictor = function (dat, min.r = 0.9) {
	require(caret)
	#nzv <- nearZeroVar(dat, saveMetrics= TRUE)
	#nzv.num = sum(nzv$nzv)
	#nzv <- nearZeroVar(dat, freqCut = 95/5, uniqueCut = 10)
	dat.bak = dat
	dat = scale(dat, scale = T, center = T)
	nzv <- nearZeroVar(dat, freqCut = 5/5, uniqueCut = 20)
	filteredDescr <- dat[, -nzv]
	nzv.num = ncol(dat) - ncol(filteredDescr)
	descrCor <-  cor(filteredDescr)
	highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > min.r)
	highlyCorDescr <- findCorrelation(descrCor, cutoff = min.r)
	dat.o <- filteredDescr[,-highlyCorDescr]
	corr.num = length(highlyCorDescr)
	dat = dat.bak[,colnames(dat.o)]
	list(dat=dat, nzv.num = nzv.num, corr.num = corr.num)
}


################SET UP#################
#input

#percentage
training_perc = 0.7
#validation_perc = 0.15
#testing_perc = 0.15

#if imputation NA with random forest
if_imputation_na = T
################SET UP#################

#source("./split_samples_para.R")

path = "~/PD_dream/Ldopa_proc_raw_features/all_training/merged_v3"

message (paste0("processing ", type, " ...  "))

input_dat = paste0(path, "/", dataf)
input_y = paste0(path, "/", responsef)
test_dat = paste0(path, "/", testf)

#response = read.delim(input_y, T)
#dat = read.delim(input_dat, T)
response = read.table(input_y, T)
dat = read.table(input_dat, T)
test.dat = read.table(test_dat, T)
rownames(response) = idx2file(rownames(response))
rownames(dat) = idx2file(rownames(dat))
print (paste0("Total training input idx: ", dim(dat)[1]))
rownames(test.dat) = idx2file.testing(rownames(test.dat))
print (paste0("Total testing input idx: ", dim(test.dat)[1]))

#keep only required idxs
fileid = read.csv(templatef, T)[,1]
#for testing
f.i = match(fileid, rownames(test.dat), nomatch=0)
nomatch.num = sum(f.i == 0)
print (paste0("Total testing unmatched idx: ", nomatch.num))
test.dat = test.dat[f.i, ]
diff.num = sum(f.i != 0)
print (paste0("Total testing matched idx: ", diff.num))
#for training
f.i = match(fileid, rownames(dat), nomatch=0)
nomatch.num = sum(f.i == 0)
print (paste0("Total training unmatched idx: ", nomatch.num))
dat = dat[f.i, ]
diff.num = sum(f.i != 0)
print (paste0("Total training matched idx: ", diff.num))

#output
response.level = c("Cont", "Case") #to output testing/validation data response as character levels to meet caret requirements
training_output  = paste0("train.dat.rdata")
testing_output  = paste0("testing.XY.rdata")
#validation_output  = "validation.XY.rdata"

#imputation
if (sum(is.na(dat)) > 0 & if_imputation_na )  {
	na.num = sum(is.na(dat))
	print (paste0("Total NA number: ", na.num))
	for(i in 1:ncol(dat)){
		dat[is.na(dat[,i]), i] <- mean(dat[,i], na.rm = TRUE);
	}
}

#sorting response as dat
s.i = match(rownames(dat), rownames(response))
if (sum(is.na(s.i))>0) stop ("Demo not contain all samples names in dat")
response = response[s.i,]
response = response[, response_col]

#check data
if (length(setdiff(rownames(response), rownames(dat))) != 0 & length(setdiff(rownames(dat), rownames(response))) != 0) 
{
	stop ("Check data or response files")
}

#remove response NA
res.na.i = which(is.na(response))
if (length(res.na.i) > 0) {
	print (paste0("response NA num: ", length(res.na.i)))
	response = response[-res.na.i]
	dat = dat[-res.na.i,]
}

#filter predictors
out.log.f = paste0(type, "_feature_filter_log.tsv")
if (file.exists(out.log.f)) system (paste0("rm -f ", out.log.f))
cat ("File", "ZeroVar.num", "HighCorr.num", "Ttest.num", "\n", sep="\t", file=out.log.f, append=T)
ret = filter.predictor(dat, min.r)
dat.o = ret$dat
dim(dat)
dim(dat.o)
dat = as.data.frame(dat.o)
nzv.num = ret$nzv.num
corr.num=ret$corr.num
#ttest filtering predictors
pv.cutoff = 0.05
CPUnum = 10
library(doParallel)
registerDoParallel(cores = CPUnum)
m.i  = match(colnames(dat), colnames(test.dat))
if (sum(is.na(m.i))>0) stop ("dat colnames error.")
output <-
	foreach (j = 1:ncol(dat), .combine = rbind) %dopar%
	{
		fit = t.test(dat[,colnames(dat)[j]], test.dat[,colnames(dat)[j]])
		pv = fit$p.value
		c(colnames(dat)[j], pv)
	}
output = data.frame(output)
output[,2] = signif(as.numeric(output[,2]), 3)
colnames(output) = c("Feature", "t.test.P")
f.i = which(output[,2] < pv.cutoff)
ttest.num = length(f.i)
if (ttest.num > 0) {
	dat2 = dat[, -f.i]
} else {
	dat2 = dat
}

cat (response_col, nzv.num, corr.num, ttest.num, "\n", sep="\t", file=out.log.f, append=T)
cat (response_col, nzv.num, corr.num, ttest.num, "\n", sep="\t")
#save(dat, test.dat, output, file="ttest.dat.rdata")
#splitting 
dat = dat2
set.seed(123)
trainIndex <- createDataPartition(response, p = .7, 
								  list = FALSE, 
								  times = 1)
train.dat = dat[trainIndex,]
testing.dat = dat[-trainIndex,]
dim(train.dat)
dim(testing.dat)

train.dat$response = num2LetterFactor(response[trainIndex])
X = testing.dat
Y = response[-trainIndex]
Y = num2LetterFactor(Y)

#obsolete
#used again, 10/23/2017
if (T) {
	if (ifcasecontrol) {
		train.dat$response = as.factor(train.dat$response)
		levels(train.dat$response) = response.level
		Y = as.factor(Y)
		levels(Y) = response.level
	}
}

#output rdata
save(train.dat, file=training_output)
save(X, Y, file=testing_output)


#####debug
type = "t"
