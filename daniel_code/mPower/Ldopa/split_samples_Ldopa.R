#!/usr/bin/env Rscript
#split samples into three parts:
#training, validation, and testing
options("scipen"=1, "digits"=4, stringsAsFactors=FALSE);
#source("~/mybiotools/r/myfunc.R");

library(caret)
library(dplyr)
library(PDdream)

args<-commandArgs(T)

kw = args[1]
ext = args[2]
#task = args[1]
#task_y = args[2]
response_col = args[3] #  "tremorScore"  #response name or No.
ifcasecontrol = as.logical(args[4])

twofiles = c("ramr", "raml", "ftnl", "ftnr")

################SET UP#################
#input
dat_header = T #if the dat file has a header

#percentage
training_perc = 0.7
#validation_perc = 0.15
#testing_perc = 0.15

#if imputation NA with random forest
if_imputation_na = T
################SET UP#################

#source("./split_samples_para.R")

cat (match(kw, twofiles), "\n")
if (is.na(match(kw, twofiles))) {
	message (paste0("processing ", kw, " no merging. "))
	input_dat = paste0("~/PD_dream/Ldopa_proc_raw_features/testing_data/table/", kw, "_", ext, ".txt")
	input_y = paste0("~/PD_dream/Ldopa_proc_raw_features/testing_data/table/", kw, "_", ext, "_y.txt")
	response = read.table(input_y,T)
	dat = read.table(input_dat,dat_header)
} else {
	message (paste0("processing ", kw, " WITH merging. "))
	input_dat = paste0("~/PD_dream/Ldopa_proc_raw_features/testing_data/table/", kw, "1_", ext, ".txt")
	input_y = paste0("~/PD_dream/Ldopa_proc_raw_features/testing_data/table/", kw, "1_", ext, "_y.txt")
	response1 = read.table(input_y,T)
	dat1 = read.table(input_dat,dat_header)
	input_dat = paste0("~/PD_dream/Ldopa_proc_raw_features/testing_data/table/", kw, "2_", ext, ".txt")
	input_y = paste0("~/PD_dream/Ldopa_proc_raw_features/testing_data/table/", kw, "2_", ext, "_y.txt")
	response2 = read.table(input_y,T)
	dat2 = read.table(input_dat,dat_header)

	response = rbind(response1, response2)
	dat = rbind(dat1, dat2)
	input_dat = paste0("~/PD_dream/Ldopa_proc_raw_features/testing_data/table/", kw, "_", ext)
}

dir = tools::file_path_sans_ext(basename(input_dat))
if (!dir.exists(dir)) {
	dir.create(dir)
}

#output
#response.level = c("Cont", "Case") #to output testing/validation data response as character levels to meet caret requirements
training_output  = paste0(dir, "/train.dat.rdata")
testing_output  = paste0(dir, "/testing.XY.rdata")
#validation_output  = "validation.XY.rdata"

#imputation
if (sum(is.na(dat)) > 0 & if_imputation_na )  {
	na.num = sum(is.na(dat))
	message (paste0("Total NA number: ", na.num))
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
	response = response[-res.na.i]
	dat = dat[-res.na.i,]
}

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
if (F) {
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

#for parameter files
system(paste0("mkdir -p ", dir, "/bagging_importance_rf"))
system(paste0("cp bagging_importance_para.R ", dir, "/bagging_importance_rf"))
system(paste0("mkdir -p ", dir, "/Feature_selection"))
system(paste0("cp feature_selection_para.R ", dir, "/Feature_selection"))

#####debug
kw = "ramr"
ext = "GENEActiv"
#task = "drnkg_GENEActiv.txt"
#task_y = "drnkg_GENEActiv_y.txt"
response_col = "dyskinesiaScore" 
ifcasecontrol = T
